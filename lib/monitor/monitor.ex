defmodule Blitz.Monitor do
  @moduledoc """
  Monitor is responsible for monitoring a list of players and fetching updates on said players

  Monitor is a GenServer which spawns a task for each summoner we are monitoring
  Each task is executed once a minute and summoners are purged after 1 hour
  """

  use GenServer
  require Logger
  alias Blitz.Http

  @type summoner_name :: String.t()

  defstruct [:name, :puuid, :match_id, :region, :timestamp]

  @spec add_summoners(summoners :: list(Http.summoner_name()), region :: Http.region()) ::
          :ok | {:error, any()}
  def add_summoners(summoners, region) do
    summoners
    |> Enum.each(&add_summoner(&1, region))
  end

  @spec add_summoner(Http.summoner_name(), Http.region()) :: :ok | {:error, any()}
  def add_summoner(summoner_name, region) do
    with {:ok, summoner} <- Http.fetch_summoner(summoner_name, region),
         {:ok, match_id} <- recent_match_for_summoner(summoner, region) do
      summoner_data = to_struct(summoner, match_id, region)

      GenServer.cast(__MODULE__, {:add, summoner_data})
      schedule_monitor(summoner_data)
      :ok
    else
      error -> error
    end
  end

  defp recent_match_for_summoner(summoner, region) do
    case Http.fetch_recent_match_ids_for_summoner(summoner.puuid, region, 1) do
      {:ok, [match_id]} ->
        {:ok, match_id}

      {:error, error} ->
        Logger.info(error)
        {:error, error}
    end
  end

  def to_struct(summoner, match_id, region) do
    %__MODULE__{
      name: summoner.name,
      puuid: summoner.puuid,
      match_id: match_id,
      region: region,
      timestamp: DateTime.utc_now()
    }
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(opts) do
    schedule_prune()

    {:ok, opts}
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:add, summoner}, state) do
    new_state = add_or_refresh_summoner_timestamp(summoner, state)

    {:noreply, new_state}
  end

  def handle_info({:monitor, summoner}, state) do
    summoner
    |> find_summoner_by_name(state)
    |> if do
      Task.async(fn ->
        case recent_match_for_summoner(summoner, summoner.region) do
          {:ok, match_id} ->
            send(__MODULE__, {:task, {:ok, summoner, match_id}})

          {:error, reason} ->
            send(__MODULE__, {:task, {:error, reason}})
        end
      end)
    end

    {:noreply, state}
  end

  def handle_info(:prune, state) do
    new_state = prune_stale_summoners(state)

    {:noreply, new_state}
  end

  def handle_info({:task, {:ok, summoner, match_id}}, state) do
    new_state =
      summoner
      |> find_and_update_summoner(match_id, state)

    schedule_monitor(summoner)
    {:noreply, new_state}
  end

  def handle_info({:task, {:error, reason}}, state) do
    Logger.error("Failed to complete task: #{reason}")
    {:noreply, state}
  end

  def handle_info({_ref, _task}, state), do: {:noreply, state}
  def handle_info({:DOWN, _ref, _process, _pid, _status}, state), do: {:noreply, state}

  def handle_info(message, state) do
    Logger.info(fn -> "unknown message recieved #{inspect(message)}" end)
    {:noreply, state}
  end

  defp schedule_monitor(summoner) do
    Logger.info("scheduling monitor for #{summoner.name}")

    Process.send_after(__MODULE__, {:monitor, summoner}, :timer.minutes(1))
  end

  defp find_and_update_summoner(summoner, match_id, state) do
    summoner
    |> find_summoner_by_name(state)
    |> case do
      nil ->
        # This is an edge case in the event that we prune the summoner before the data gets returned
        state

      %{name: name, match_id: last_match} ->
        if last_match != match_id do
          Logger.info("Summoner #{name} completed match #{last_match}")
        end

        update_summoner(%__MODULE__{summoner | match_id: match_id}, state)
    end
  end

  defp find_summoner_by_name(%{name: summoner_name}, state) do
    Enum.find(state, fn %{name: name} ->
      name == summoner_name
    end)
  end

  defp find_summoner_index_by_name(%{name: summoner_name}, state) do
    Enum.find_index(state, fn %{name: name} ->
      name == summoner_name
    end)
  end

  defp add_or_refresh_summoner_timestamp(summoner, state) do
    summoner
    |> find_summoner_index_by_name(state)
    |> case do
      nil ->
        [summoner | state]

      index ->
        List.replace_at(state, index, %{summoner | timestamp: DateTime.utc_now()})
    end
  end

  defp update_summoner(summoner, state) do
    summoner
    |> find_summoner_index_by_name(state)
    |> case do
      nil ->
        [summoner | state]

      index ->
        List.replace_at(state, index, summoner)
    end
  end

  defp schedule_prune() do
    Process.send_after(__MODULE__, :prune, :timer.minutes(5))
  end

  defp prune_stale_summoners(state) do
    Logger.info("pruning stale summoners")
    hour_ago =
      DateTime.utc_now()
      |> DateTime.add(-1, :hour)

    new_state =
      state
      |> Enum.reject(fn %{timestamp: timestamp} ->
        timestamp < hour_ago
      end)

    Logger.info("New summoner_count: #{length(new_state)}")

    schedule_prune()

    new_state
  end
end
