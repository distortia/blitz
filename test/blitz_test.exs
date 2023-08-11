defmodule BlitzTest do
  use Blitz.Case, async: true
  alias Blitz.HttpMock

  setup :verify_on_exit!

  setup do
    name = username()
    %{puuid: summoner_id} = summoner = build(:summoner, name: name)
    region = region_id()
    matches = build_list(5, :match)
    player_list = Enum.flat_map(matches, &get_players_from_match/1)
    match_ids = 1..5 |> Enum.map(fn _ -> match_id() end)
    %{metadata: %{match_id: match_id}} = match = hd(matches)

    HttpMock
    |> stub(:fetch_summoner, fn ^name, ^region -> {:ok, summoner} end)
    |> stub(:fetch_recent_match_ids_for_summoner, fn ^summoner_id, ^region, 5 ->
      {:ok, match_ids}
    end)
    |> stub(:fetch_match, fn ^match_id, ^region -> {:ok, match} end)

    ~M{name, summoner, summoner_id, region, matches, match, match_id, match_ids, player_list}
  end

  test "fetching summoner by name and region", ~M{summoner, name, region} do
    assert {:ok, summoner} == Blitz.get_summoner_by_name(name, region)
  end

  test "recent_matches_for_summoner", ~M{summoner_id, region, match_ids} do
    assert {:ok, match_ids} == Blitz.recent_matches_for_summoner(summoner_id, region)
  end

  test "fetching a match returns the participants", ~M{match_id, match, region} do
    player_list = get_players_from_match(match)
    assert player_list == Blitz.recent_players_from_match_id(match_id, region)
  end

  defp get_players_from_match(match) do
    match.info.participants |> Enum.map(&Map.get(&1, :summonerName))
  end
end
