defmodule Blitz.Http do
  @moduledoc """
  Http is responsible for all requests made outside the application
  """

  @type error :: {:error, String.t()}
  @type match_id :: String.t()
  @type match :: map()
  @type name() :: String.t()
  @type region() :: String.t()
  @type summoner_id :: String.t()

  @callback fetch_summoner(name :: name(), region :: region()) ::
              {:ok, any()} | error()
  def fetch_summoner(name, region), do: impl().fetch_summoner(name, region)

  @callback fetch_recent_match_ids_for_summoner(
              summoner_id :: summoner_id(),
              region :: region(),
              match_count :: non_neg_integer()
            ) :: {:ok, list(String.t())} | error()
  def fetch_recent_match_ids_for_summoner(summoner_id, region, match_count \\ 5),
    do: impl().fetch_recent_match_ids_for_summoner(summoner_id, region, match_count)

  @callback fetch_match(match_id :: match_id(), region :: region()) :: {:ok, match()} | error()
  def fetch_match(match_id, region), do: impl().fetch_match(match_id, region)

  defp impl, do: Application.get_env(:blitz, :http, Blitz.HttpImpl)
end
