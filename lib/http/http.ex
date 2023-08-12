defmodule Blitz.Http do
  @moduledoc """
  The HTTP client responsible for any requests made to the Riot API
  Riot Docs: https://developer.riotgames.com/apis#summoner-v4/
  """

  @type error :: {:error, String.t()}
  @type match :: map()
  @type match_id :: String.t()
  @type match_ids :: list(match_id())
  @type region() :: String.t()
  @type summoner :: map()
  @type summoner_id :: String.t()
  @type summoner_name() :: String.t()

  @callback fetch_summoner(summoner_name :: summoner_name(), region :: region()) ::
              {:ok, summoner()} | error()
  def fetch_summoner(summoner_name, region), do: impl().fetch_summoner(summoner_name, region)

  @callback fetch_recent_match_ids_for_summoner(
              summoner_id :: summoner_id(),
              region :: region(),
              match_count :: non_neg_integer()
            ) :: {:ok, match_ids()} | error()
  def fetch_recent_match_ids_for_summoner(summoner_id, region, match_count),
    do: impl().fetch_recent_match_ids_for_summoner(summoner_id, region, match_count)

  @callback fetch_match(match_id :: match_id(), region :: region()) :: {:ok, match()} | error()
  def fetch_match(match_id, region), do: impl().fetch_match(match_id, region)

  defp impl, do: Application.get_env(:blitz, :http, Blitz.HttpImpl)
end
