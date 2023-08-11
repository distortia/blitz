defmodule Blitz.HttpImpl do
  @moduledoc """
  The Riot HTTP client responsible for any requests made to the Riot API
  Riot Docs: https://developer.riotgames.com/apis#summoner-v4/
  """
  require Logger

  alias Blitz.Http
  alias Req
  alias Req.Response

  @behaviour Http

  @regions [
    "br1",
    "eun1",
    "euw1",
    "jp1",
    "kr",
    "la1",
    "la2",
    "na1",
    "oc1",
    "ph2",
    "ru",
    "sg2",
    "th2",
    "tr1",
    "tw2",
    "vn2"
  ]
  @american_regions ["br1", "na1", "la1", "la2"]
  @asian_regions ["kr", "jp1"]
  @europe_regions ["eun1", "euw1", "tr1", "tw2"]
  @sea_regions ["oc1", "ph2", "sg2", "th2", "vn2"]

  @doc """
  Looks up the given summoners name and region.
  Riot states that any summoner can be queried by any region but we want things to be fast

  Returns {:ok, summoner} or {:error, reason}
  """
  @impl Http
  def fetch_summoner(name, region) do
    with :ok <- valid_region?(region),
         req <- base_req(),
         {:ok, %Response{status: 200, body: body}} <-
           Req.get(req,
             decode_json: [keys: :atoms],
             url:
               "https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{URI.encode(name)}"
           ) do
      {:ok, body}
    else
      error ->
        handle_error(error)
    end
  end

  @doc """
  Looks up the given summoners match history for the most recent `match_count` matches
  Returns {:ok, [match_ids]} or {:error, reason} with most recent match first
  """
  @impl Http
  def fetch_recent_match_ids_for_summoner(summoner_id, region, match_count) do
    with :ok <- valid_region?(region),
         {:ok, match_region} <- match_region(region),
         req <- base_req(),
         {:ok, %Response{status: 200, body: body}} <-
           Req.get(req,
             decode_json: [keys: :atoms],
             url:
               "https://#{match_region}.api.riotgames.com/lol/match/v5/matches/by-puuid/#{summoner_id}/ids?start=0&count=#{match_count}"
           ) do
      {:ok, body}
    else
      error -> handle_error(error)
    end
  end

  @doc """
  Looks up the given match and returns it
  Returns {:ok, match} or {:error, reason}
  """
  @impl Http
  def fetch_match(match_id, region) do
    with :ok <- valid_region?(region),
         {:ok, match_region} <- match_region(region),
         req <- base_req(),
         {:ok, %Response{status: 200, body: body}} <-
           Req.get(req,
             decode_json: [keys: :atoms],
             url: "https://#{match_region}.api.riotgames.com/lol/match/v5/matches/#{match_id}"
           ) do
      {:ok, body}
    else
      error -> handle_error(error)
    end
  end

  defp valid_region?(region) do
    if Enum.member?(@regions, region) do
      :ok
    else
      {:error, "invalid_region"}
    end
  end

  # Api servers are different for summoner info and match info
  defp match_region(region) do
    cond do
      Enum.member?(@american_regions, region) ->
        {:ok, "americas"}

      Enum.member?(@asian_regions, region) ->
        {:ok, "asia"}

      Enum.member?(@europe_regions, region) ->
        {:ok, "europe"}

      Enum.member?(@sea_regions, region) ->
        {:ok, "sea"}

      true ->
        {:error, "invalid region"}
    end
  end

  defp handle_error({:ok, %Response{status: 403}}), do: {:error, "invalid api key"}
  defp handle_error({:ok, %Response{status: 404}}), do: {:error, "not found"}
  defp handle_error({:ok, %Response{status: 429}}), do: {:error, "rate limit exceeded"}

  defp handle_error(error) do
    Logger.error(fn -> "#{inspect(error)}" end)
    {:error, "unknown error occured"}
  end

  defp base_req() do
    Req.new(headers: ["X-Riot-Token": Application.fetch_env!(:blitz, :riot_api_key)])
  end
end
