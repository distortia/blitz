defmodule Blitz.HttpImpl do
  @moduledoc """
  The Riot HTTP client responsible for any requests made to the Riot API
  """
  alias Blitz.Http
  @behaviour Http

  @doc """
  Looks up the given summoners name and region

  Returns {:ok, summoner} or {:error, reason}
  """
  @impl Http
  def fetch_summoner(name, region) do
    {:error, "bad"}
  end
end
