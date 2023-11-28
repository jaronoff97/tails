defmodule Opamp.Proto.AnyValue do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  oneof :value, 0

  field :string_value, 1, type: :string, json_name: "stringValue", oneof: 0
  field :bool_value, 2, type: :bool, json_name: "boolValue", oneof: 0
  field :int_value, 3, type: :int64, json_name: "intValue", oneof: 0
  field :double_value, 4, type: :double, json_name: "doubleValue", oneof: 0
  field :array_value, 5, type: Opamp.Proto.ArrayValue, json_name: "arrayValue", oneof: 0
  field :kvlist_value, 6, type: Opamp.Proto.KeyValueList, json_name: "kvlistValue", oneof: 0
  field :bytes_value, 7, type: :bytes, json_name: "bytesValue", oneof: 0
end

defmodule Opamp.Proto.ArrayValue do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :values, 1, repeated: true, type: Opamp.Proto.AnyValue
end

defmodule Opamp.Proto.KeyValueList do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :values, 1, repeated: true, type: Opamp.Proto.KeyValue
end

defmodule Opamp.Proto.KeyValue do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :key, 1, type: :string
  field :value, 2, type: Opamp.Proto.AnyValue
end