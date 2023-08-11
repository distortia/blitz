# Blitz

## Installation

Set the API key as an environment variable before running: `RIOT_API_KEY=<xyz> iex -S mix` or `export RIOT_API_KEY=<xyz>` and run `iex -S mix` afterwards

Or you can set it directly in the dev config with the following:

`config :blitz, riot_api_key: "RGAPI-<my key>"`


```
mix deps.get

iex -S mix

Blitz.main("summoner name", "region")
```

