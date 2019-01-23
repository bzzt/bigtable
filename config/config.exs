use Mix.Config

config :goth,
  disabled: true

import_config "#{Mix.env()}.exs"
