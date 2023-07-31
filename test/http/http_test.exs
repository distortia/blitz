defmodule Blitz.HttpTest do
  use Blitz.Case, async: true
  alias Blitz.Http
  alias Blitz.HttpMock

  setup :verify_on_exit!

  describe "fetch_summoner" do
    setup do
      %{name: username} = summoner = build(:summoner)
      region = region_id()

      ~M{username, summoner, region}
    end

    test "returns the summoner", ~M{username, summoner, region} do
      HttpMock
      |> expect(:fetch_summoner, fn ^username, ^region -> {:ok, summoner} end)

      assert {:ok, summoner} == Http.fetch_summoner(username, region)
    end

    test "returns not found when user does not exist", ~M{region} do
      invalid_username = "invalid_user"

      HttpMock
      |> expect(:fetch_summoner, fn ^invalid_username, ^region ->
        {:error, "summoner not found"}
      end)

      assert {:error, "summoner not found"} == Http.fetch_summoner(invalid_username, region)
    end

    test "returns an error when region is not valid", ~M{username} do
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

    test "returns an error when api key is invalid", ~M{username, region} do
      HttpMock
      |> expect(:fetch_summoner, fn ^username, ^region -> {:error, "invalid api key"} end)

      assert {:error, "invalid api key"} == Http.fetch_summoner(username, region)
    end

    test "returns an error when anything else goes wrong", ~M{username, region} do
      HttpMock
      |> expect(:fetch_summoner, fn ^username, ^region -> {:error, "unknown error occurred"} end)

      assert {:error, "unknown error occurred"} == Http.fetch_summoner(username, region)
    end
  end

  describe "fetch_matches" do
    setup do
      %{puuid: summoner_id} = summoner = build(:summoner)
      match_count = 5
      region = region_id()

      ~M{match_count, summoner_id, region}
    end

    test "returns a list of match ids for the given player",
         ~M{match_count, summoner_id, region} do
      matches = 1..5 |> Enum.map(fn _ -> match_id() end)

      HttpMock
      |> expect(:fetch_recent_match_ids_for_summoner, fn ^summoner_id, ^region, ^match_count ->
        {:ok, matches}
      end)

      assert {:ok, matches} ==
               Http.fetch_recent_match_ids_for_summoner(summoner_id, region, match_count)
    end

    test "returns an error when summoner is invalid", ~M{match_count, region} do
      invalid_summoner_id = "invalid_user"

      HttpMock
      |> expect(:fetch_recent_match_ids_for_summoner, fn ^invalid_summoner_id,
                                                         ^region,
                                                         ^match_count ->
        {:error, "not found"}
      end)

      assert {:error, "not found"} ==
               Http.fetch_recent_match_ids_for_summoner(invalid_summoner_id, region, match_count)
    end

    test "returns an error if the given region is invalid", ~M{match_count, summoner_id} do
      region = "invalid_region"

      HttpMock
      |> expect(:fetch_recent_match_ids_for_summoner, fn ^summoner_id, ^region, ^match_count ->
        {:error, "invalid region"}
      end)

      assert {:error, "invalid region"} ==
               Http.fetch_recent_match_ids_for_summoner(summoner_id, region, match_count)
    end

    test "returns an error when api key is invalid", ~M{summoner_id, region, match_count} do
      HttpMock
      |> expect(:fetch_recent_match_ids_for_summoner, fn ^summoner_id, ^region, ^match_count ->
        {:error, "invalid api key"}
      end)

      assert {:error, "invalid api key"} ==
               Http.fetch_recent_match_ids_for_summoner(summoner_id, region, match_count)
    end
  end

  describe "fetch_match" do
    setup do
      region = region_id()
      %{metadata: %{match_id: match_id}} = match = build(:match)

      ~M{match_id, match, region}
    end

    test "returns the match from the given match_id", ~M{match_id, match, region} do
      HttpMock
      |> expect(:fetch_match, fn ^match_id, ^region -> {:ok, match} end)

      assert {:ok, match} == Http.fetch_match(match_id, region)
    end

    test "returns an error when match id is invalid", ~M{region} do
      invalid_match_id = "invalid_match_id"

      HttpMock
      |> expect(:fetch_match, fn ^invalid_match_id, ^region ->
        {:error, "not found"}
      end)

      assert {:error, "not found"} == Http.fetch_match(invalid_match_id, region)
    end

    test "returns an error if the given region is invalid", ~M{match_id} do
      invalid_region = "invalid_region"

      HttpMock
      |> expect(:fetch_match, fn ^match_id, ^invalid_region ->
        {:error, "invalid region"}
      end)

      assert {:error, "invalid region"} == Http.fetch_match(match_id, invalid_region)
    end

    test "returns an error when api key is invalid", ~M{match_id, region} do
      HttpMock
      |> expect(:fetch_match, fn ^match_id, ^region -> {:error, "invalid api key"} end)

      assert {:error, "invalid api key"} == Http.fetch_match(match_id, region)
    end
  end
end
