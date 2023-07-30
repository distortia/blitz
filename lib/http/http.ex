defmodule Blitz.Http do
  @moduledoc """
  Http is responsible for all requests made outside the application
  """
  alias Req.Response

  @type name() :: String.t()
  @type region() :: String.t()

  @callback fetch_summoner(name :: name(), region :: region()) :: {:ok, any()} | {:error, any()}
  def fetch_summoner(name, region), do: impl().fetch_summoner(name, region)

  defp impl, do: Application.get_env(:blitz, :http, Blitz.HttpImpl)
end
