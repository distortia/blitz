defmodule Blitz.Http do
  @moduledoc """
  Http is responsible for all requests made outside the application
  """

  @type name() :: String.t()
  @type region() :: String.t()
  @type summoner_id :: String.t()

  @callback fetch_summoner(name :: name(), region :: region()) ::
              {:ok, any()} | {:error, String.t()}
  def fetch_summoner(name, region), do: impl().fetch_summoner(name, region)

  @callback fetch_matches_for_summoner(
              summoner_id :: summoner_id(),
              region :: region(),
              match_count :: non_neg_integer()
            ) :: {:ok, list(String.t())} | {:error, String.t()}
  def fetch_matches_for_summoner(summoner_id, region, match_count \\ 5),
    do: impl().fetch_matches_for_summoner(summoner_id, region, match_count)

  defp impl, do: Application.get_env(:blitz, :http, Blitz.HttpImpl)
end
