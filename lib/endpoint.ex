defmodule Bigtable.Endpoint do
  use GRPC.Endpoint

  intercept(GRPC.Logger.Server)
end
