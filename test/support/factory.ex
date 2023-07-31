defmodule Blitz.Factory do
  @moduledoc false
  use ExMachina

  # Helper functions
  def match_id, do: region_id() <> "_" <> Faker.UUID.v4()
  def username, do: Faker.Internet.user_name()

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
    1..10 |> Enum.map(fn _ -> Faker.UUID.v4() end)
  end

  def summoner_factory do
    %{
      id: Faker.UUID.v4(),
      accountId: Faker.UUID.v4(),
      puuid: Faker.UUID.v4(),
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
        participants: player_list()
      },
      info: %{
        participants: player_list()
      }
    }
  end
end
