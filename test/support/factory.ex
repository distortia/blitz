defmodule Blitz.Factory do
  use ExMachina

  # Helper functions
  def match_id, do: region_id() <> "_" <> Faker.UUID.v4()

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

  def summoner_factory do
    %{
      id: Faker.UUID.v4(),
      accountId: Faker.UUID.v4(),
      puuid: Faker.UUID.v4(),
      name: Faker.Internet.user_name(),
      profileIconId: 3542,
      revisionDate: 1_623_472_262_000,
      summonerLevel: Faker.random_between(1, 100)
    }
  end
end
