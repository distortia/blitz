defmodule Blitz.MonitorTest do
  use Blitz.Case, async: true
  import ExUnit.CaptureLog
  alias Blitz.Monitor
  alias Blitz.HttpMock
  require Logger

  describe "Monitor" do
    test "can be started up" do
      assert {:ok, _} = Monitor.start_link()
    end

    test "starts with an initial state" do
      {:ok, pid} = Monitor.start_link()
      assert [] == GenServer.call(pid, :list)
    end

    test "can add a summoner to be monitored" do
      {:ok, pid} = Monitor.start_link()
      summoner = build(:summoner) |> monitor_data()
      :ok = GenServer.cast(pid, {:add, summoner})
      assert [summoner] == GenServer.call(pid, :list)
    end

    @tag :capture_log
    test "can monitor a summoner" do
      %{name: username, puuid: puuid, region: region, match_id: match_id} =
        summoner = build(:summoner) |> monitor_data()

      HttpMock
      |> expect(:fetch_summoner, fn ^username, ^region -> {:ok, summoner} end)
      |> expect(:fetch_recent_match_ids_for_summoner, fn ^puuid, ^region, 1 ->
        {:ok, [match_id]}
      end)

      assert capture_log(fn ->
               Monitor.add_summoner(summoner.name, summoner.region)
             end) =~ "scheduling monitor for #{username}"
    end

    test "can update a summoner's timestamp if the summoner already exists" do
      {:ok, pid} = Monitor.start_link()
      summoner = build(:summoner) |> monitor_data()
      :ok = GenServer.cast(pid, {:add, summoner})
      [%{timestamp: timestamp}] = GenServer.call(pid, :list)
      :ok = GenServer.cast(pid, {:add, summoner})
      [%{timestamp: new_timestamp}] = GenServer.call(pid, :list)

      refute new_timestamp == timestamp
    end

    @tag :capture_log
    test "can update and notify if a summoner's match id changes" do
      %{puuid: summoner_id, region: region, match_id: last_match} =
        summoner = build(:summoner) |> monitor_data()

      assert capture_log(fn ->
               {:ok, pid} = Monitor.start_link()
               new_match = match_id()

               :ok = GenServer.cast(pid, {:add, summoner})

               HttpMock
               |> stub(:fetch_recent_match_ids_for_summoner, fn ^summoner_id, ^region, 1 ->
                 {:ok, [new_match]}
               end)

               send(pid, {:task, {:ok, summoner, new_match}})
               Process.sleep(500)
             end) =~ "Summoner #{summoner.name} completed match #{last_match}"
    end

    test "removes the summoner after 1 hour" do
      {:ok, pid} = Monitor.start_link()

      hour_ago =
        DateTime.utc_now()
        |> DateTime.add(-62, :minute)

      summoner = build(:summoner) |> monitor_data(hour_ago)
      :ok = GenServer.cast(pid, {:add, summoner})
      assert [^summoner] = GenServer.call(pid, :list)
      send(pid, :prune)
      assert [] == GenServer.call(pid, :list)
    end
  end
end
