import Config

if Mix.env() == :dev do
  config :mix_test_interactive, clear: true
end

import_config "#{config_env()}.exs"
