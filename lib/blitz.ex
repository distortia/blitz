defmodule Blitz do
  @moduledoc """
  Documentation for `Blitz`.
  """

  alias Blitz.Http

  @type summoner_name :: String.t()

  @spec main(summoner_name :: summoner_name(), region :: Http.region()) ::
          list(summoner_name()) | {:error, String.t()}
  def main(summoner_name, region) do
    with {:ok, summoner_id} <- get_summoner_by_name(summoner_name, region),
         {:ok, match_ids} <- Http.fetch_recent_match_ids_for_summoner(summoner_id, region),
         {:ok, recent_players} <- recent_players_from_match_ids(match_ids, region) do
      recent_players
    else
      error ->
        error
    end
  end

  def get_summoner_by_name(summoner_name, region) do
    with {:ok, %{"puuid" => summoner_id}} <- Http.fetch_summoner(summoner_name, region) do
      {:ok, summoner_id}
    end
  end

  def recent_players_from_match_ids(match_ids, region) do
    # TODO: handle error from api calls
    recent_players =
      match_ids
      |> Enum.flat_map(&recent_players_from_match_id(&1, region))
      |> Enum.uniq()

    {:ok, recent_players}
  end

  def recent_players_from_match_id(match_id, region) do
    with {:ok, match} <- Http.fetch_match(match_id, region) do
      match
      |> Map.get("metadata")
      |> Map.get("participants")
    end
  end
end
