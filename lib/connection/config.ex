defmodule Bigtable.Connection.Config do
  @type t :: %__MODULE__{
          client_config: %{},
          service_path: binary(),
          port: integer(),
          ssl_creds: any(),
          options: __MODULE__.Options.t()
        }
  defstruct client_config: %{}, service_path: nil, port: nil, ssl_creds: nil, options: nil
end

defmodule Bigtable.Connection.Config.Options do
  @type t :: %__MODULE__{
          lib_name: binary(),
          lib_version: binary(),
          scopes: [binary()],
          max_send_message_length: integer(),
          max_receive_message_length: integer()
        }
  defstruct lib_name: "gccl",
            lib_version: "1.0.0",
            scopes: [
              "https://www.googleapis.com/auth/bigtable.data",
              "https://www.googleapis.com/auth/bigtable.data.readonly",
              "https://www.googleapis.com/auth/cloud-bigtable.data",
              "https://www.googleapis.com/auth/cloud-bigtable.data.readonly",
              "https://www.googleapis.com/auth/cloud-platform",
              "https://www.googleapis.com/auth/cloud-platform.read-only",
              "https://www.googleapis.com/auth/bigtable.admin",
              "https://www.googleapis.com/auth/bigtable.admin.cluster",
              "https://www.googleapis.com/auth/bigtable.admin.instance",
              "https://www.googleapis.com/auth/bigtable.admin.table",
              "https://www.googleapis.com/auth/cloud-bigtable.admin",
              "https://www.googleapis.com/auth/cloud-bigtable.admin.cluster",
              "https://www.googleapis.com/auth/cloud-bigtable.admin.table"
            ],
            max_send_message_length: -1,
            max_receive_message_length: -1
end
