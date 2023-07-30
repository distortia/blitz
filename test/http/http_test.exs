defmodule Blitz.HttpTest do
	use Blitz.Case, async: true
	alias Blitz.Http
  alias Blitz.HttpMock

  setup :verify_on_exit!

  describe "Http" do
    test "returns an error when summoner name and region are not found" do
      HttpMock
      |> stub(:fetch_summoner, fn "invalid_user", "invalid_region" -> {:error, "bad"} end)

      assert {:error, "bad"} == Http.fetch_summoner("invalid_user", "invalid_region")
    end
  end
end
