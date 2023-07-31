defmodule Blitz.Factory do
  @moduledoc false
  use ExMachina

  # Helper functions
  def match_id, do: region_id() <> "_" <> Faker.UUID.v4()
  def username, do: Faker.Internet.user_name()
  def puuid, do: Faker.UUID.v4()

  def region_id do
    [
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
    |> Enum.random()
  end

  def match_region_id do
    ["americas", "europe", "asia", "sea"]
    |> Enum.random()
  end

  def player_list do
    1..10 |> Enum.map(fn _ -> username() end)
  end

  def player_factory do
    %{
      summonerName: username(),
      puuid: puuid()
    }
  end

  def summoner_factory do
    %{
      id: Faker.UUID.v4(),
      accountId: Faker.UUID.v4(),
      puuid: puuid(),
      name: username(),
      profileIconId: 3542,
      revisionDate: 1_623_472_262_000,
      summonerLevel: Faker.random_between(1, 100)
    }
  end

  def match_factory do
    %{
      metadata: %{
        match_id: match_id(),
        participants: build_list(10, :player)
      },
      info: %{
        participants: build_list(10, :player)
      }
    }
  end
end
