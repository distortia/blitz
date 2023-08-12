defmodule Blitz do
  @moduledoc false

  alias Blitz.Http
  alias Blitz.Monitor

  @type match_count :: non_neg_integer()
  @type players :: String.t()
  @type player_list :: list(players())

  @doc """
  `main/2` is the main function for the Blitz app.
  It is responsible for looking up a summoner by name and region and fetching all the unique players
  from the last 5 matches while monitoring each player for the next hour.
  """
  @spec main(summoner_name :: Http.summoner_name(), region :: Http.region()) ::
          list(Http.summoner_name()) | Http.error()
  def main(summoner_name, region) do
    with {:ok, summoner} <- get_summoner_by_name(summoner_name, region),
         {:ok, match_ids} <- recent_matches_for_summoner(summoner.puuid, region),
         {:ok, recent_players} <- recent_players_from_match_ids(match_ids, region),
         :ok <- Monitor.add_summoners(recent_players, region) do
      recent_players
    else
      error ->
        error
    end
  end

  @doc """
  `get_summoner_by_name/2` calls the `Http` module to get the summoner by name
  """
  @spec get_summoner_by_name(summoner_name :: Http.summoner_name(), region :: Http.region()) ::
          {:ok, Http.summoner()} | Http.error()
  def get_summoner_by_name(summoner_name, region) do
    Http.fetch_summoner(summoner_name, region)
  end

  @doc """
  `recent_matches_for_summoner/2/3` calls the `Http` module to fetch the most recent matches for the given `summoner_puuid`
  """
  @spec recent_matches_for_summoner(
          summoner_id :: Http.summoner_id(),
          region :: Http.region(),
          match_count :: match_count()
        ) :: {:ok, Http.match_ids()} | Http.error()
  def recent_matches_for_summoner(summoner_id, region, match_count \\ 5) do
    Http.fetch_recent_match_ids_for_summoner(summoner_id, region, match_count)
  end

  @doc """
  `recent_players_from_match_ids/2` iterates over the given `match_ids` and region to fetch all players in the match
  """
  @spec recent_players_from_match_ids(match_ids :: Http.match_ids(), region :: Http.region()) ::
          {:ok, player_list()}
  def recent_players_from_match_ids(match_ids, region) do
    recent_players =
      match_ids
      |> Enum.flat_map(&recent_players_from_match_id(&1, region))
      |> Enum.uniq()

    {:ok, recent_players}
  end

  @doc """
  `recent_players_from_match_id/2` takes a `match_id` and `region` to call the `Http` module to fetch the match to grab the players' names
  """
  @spec recent_players_from_match_id(match_id :: Http.match_id(), region :: Http.region()) ::
          player_list() | Http.error()
  def recent_players_from_match_id(match_id, region) do
    with {:ok, match} <- Http.fetch_match(match_id, region) do
      match
      |> Map.get(:info)
      |> Map.get(:participants)
      |> Enum.map(&Map.get(&1, :summonerName))
    end
  end
end
