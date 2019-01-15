# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module
use Mix.Config

config :bigtable,
  project: "datahub-222411",
  instance: "dev-instance",
  table: "ride",
  url: "bigtable.googleapis.com/projects/datahub-222411/instances/dev-instance/tables/ride",
  port: "443"
