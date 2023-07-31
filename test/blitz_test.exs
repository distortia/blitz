defmodule BlitzTest do
  use Blitz.Case, async: true
  alias Blitz.HttpMock

  setup :verify_on_exit!

  setup do
    name = username()
    %{puuid: summoner_id} = summoner = build(:summoner, name: name)
    region = region_id()
    player_list = player_list()
    matches = build_list(5, :match)
    %{metadata: %{match_id: match_id}} = match = hd(matches)

    HttpMock
    |> stub(:fetch_summoner, fn ^name, ^region -> {:ok, summoner} end)
    |> stub(:fetch_recent_match_ids_for_summoner, fn ^summoner_id, ^region, 5 ->
      {:ok, matches}
    end)
    |> stub(:fetch_match, fn ^match_id, ^region -> {:ok, match} end)

    ~M{name, summoner, summoner_id, region, player_list, matches}
  end

  test "fetching summoner by name and region", ~M{summoner, name, region} do
    assert {:ok, summoner} == Blitz.get_summoner_by_name(name, region)
  end

  test "get_recent_matches_for_summoner", ~M{summoner_id, region, matches} do
    assert {:ok, matches} == Blitz.get_recent_matches_for_summoner(summoner_id, region)
  end

  test "fetching a match returns the participants" do
  end
end
