use Mix.Config

config :pre_commit,
  commands: ["test", "coveralls", "credo"],
  verbose: true

import_config "#{Mix.env()}.exs"
