import Config

if config_env() == :prod do
  riot_api_key =
    System.get_env("RIOT_API_KEY") ||
      raise """
      Environment variable `RIOT_API_KEY` is missing.
      Please set it and try again
      """

  config :blitz, riot_api_key: riot_api_key
end
