defmodule Google.Api.Http do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          rules: [Google.Api.HttpRule.t()],
          fully_decode_reserved_expansion: boolean
        }
  defstruct [:rules, :fully_decode_reserved_expansion]

  field :rules, 1, repeated: true, type: Google.Api.HttpRule
  field :fully_decode_reserved_expansion, 2, type: :bool
end

defmodule Google.Api.HttpRule do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          pattern: {atom, any},
          selector: String.t(),
          body: String.t(),
          response_body: String.t(),
          additional_bindings: [Google.Api.HttpRule.t()]
        }
  defstruct [:pattern, :selector, :body, :response_body, :additional_bindings]

  oneof :pattern, 0
  field :selector, 1, type: :string
  field :get, 2, type: :string, oneof: 0
  field :put, 3, type: :string, oneof: 0
  field :post, 4, type: :string, oneof: 0
  field :delete, 5, type: :string, oneof: 0
  field :patch, 6, type: :string, oneof: 0
  field :custom, 8, type: Google.Api.CustomHttpPattern, oneof: 0
  field :body, 7, type: :string
  field :response_body, 12, type: :string
  field :additional_bindings, 11, repeated: true, type: Google.Api.HttpRule
end

defmodule Google.Api.CustomHttpPattern do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          kind: String.t(),
          path: String.t()
        }
  defstruct [:kind, :path]

  field :kind, 1, type: :string
  field :path, 2, type: :string
end
