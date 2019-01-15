options = %{
  libName: "gccl",
  libVersion: "1.0.0",
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
  :"grpc.max_send_message_length": -1,
  :"grpc.max_receive_message_length": -1
}

defaultBaseUrl = "bigtable.googleapis.com";
defaultAdminBaseUrl = "bigtableadmin.googleapis.com";
