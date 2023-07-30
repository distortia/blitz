defmodule Blitz.HttpTest do
  use Blitz.Case, async: true
  alias Blitz.Http
  alias Blitz.HttpMock

  setup :verify_on_exit!

  describe "fetch_summoner" do
    test "returns the summoner" do
      username = Faker.Internet.user_name()
      summoner = build(:summoner, name: username)
      region = region_id()

      HttpMock
      |> expect(:fetch_summoner, fn ^username, ^region -> {:ok, summoner} end)

      assert {:ok, summoner} == Http.fetch_summoner(username, region)
    end

    test "returns not found when user does not exist" do
      invalid_username = "invalid_user"
      region = region_id()

      HttpMock
      |> expect(:fetch_summoner, fn ^invalid_username, ^region ->
        {:error, "summoner not found"}
      end)

      assert {:error, "summoner not found"} == Http.fetch_summoner(invalid_username, region)
    end

    test "returns an error when region is not valid" do
      username = Faker.Internet.user_name()
      invalid_region = "invalid_region"

      HttpMock
      |> expect(:fetch_summoner, fn ^username, ^invalid_region -> {:error, "invalid region"} end)

      assert {:error, "invalid region"} == Http.fetch_summoner(username, invalid_region)
    end

    test "returns an error when summoner name and region are not found" do
      invalid_username = "invalid_user"
      invalid_region = "invalid_region"

      HttpMock
      |> expect(:fetch_summoner, fn ^invalid_username, ^invalid_region ->
        {:error, "not found"}
      end)

      assert {:error, "not found"} == Http.fetch_summoner(invalid_username, invalid_region)
    end

    test "returns an error when api key is invalid" do
      username = Faker.Internet.user_name()
      region = region_id()

      HttpMock
      |> expect(:fetch_summoner, fn ^username, ^region -> {:error, "invalid api key"} end)

      assert {:error, "invalid api key"} == Http.fetch_summoner(username, region)
    end

    test "returns an error when anything else goes wrong" do
      username = Faker.Internet.user_name()
      region = region_id()

      HttpMock
      |> expect(:fetch_summoner, fn ^username, ^region -> {:error, "unknown error occurred"} end)

      assert {:error, "unknown error occurred"} == Http.fetch_summoner(username, region)
    end
  end

  describe "fetch_matches" do
    setup do
      summoner = build(:summoner)
      summoner_id = summoner.puuid
      region = region_id()

      {:ok, summoner_id: summoner_id, region: region}
    end

    test "returns a list of matches for the given player", %{
      summoner_id: summoner_id,
      region: region
    } do
      matches = 1..5 |> Enum.map(fn _ -> match_id() end)

      HttpMock
      |> expect(:fetch_matches_for_summoner, fn ^summoner_id, ^region, 5 -> {:ok, matches} end)

      assert {:ok, matches} == Http.fetch_matches_for_summoner(summoner_id, region)
    end

    test "returns an error when summoner is invalid", %{region: region} do
      invalid_summoner_id = "invalid_user"

      HttpMock
      |> expect(:fetch_matches_for_summoner, fn ^invalid_summoner_id, ^region, 5 ->
        {:error, "not found"}
      end)

      assert {:error, "not found"} == Http.fetch_matches_for_summoner(invalid_summoner_id, region)
    end

    test "returns an error if the given region is invalid", %{summoner_id: summoner_id} do
      region = "invalid_region"

      HttpMock
      |> expect(:fetch_matches_for_summoner, fn ^summoner_id, ^region, 5 ->
        {:error, "invalid region"}
      end)

      assert {:error, "invalid region"} == Http.fetch_matches_for_summoner(summoner_id, region)
    end

    test "returns an error when api key is invalid" do
      username = Faker.Internet.user_name()
      region = region_id()

      HttpMock
      |> expect(:fetch_summoner, fn ^username, ^region -> {:error, "invalid api key"} end)

      assert {:error, "invalid api key"} == Http.fetch_summoner(username, region)
    end
  end
end
