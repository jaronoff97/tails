defmodule Tails.OpAMP.Helpers do
  import Bitwise

  def attributes_to_map(attributes, opts \\ []) do
    Enum.reduce(attributes, %{}, fn %Opamp.Proto.KeyValue{key: key, value: value}, acc ->
      Map.put(acc, key, clean_any_value(value, opts))
    end)
  end

  @spec clean_any_value(Opamp.Proto.AnyValue.t(), Keyword.t()) ::
          String.t()
          | boolean()
          | integer()
          | float()
          | [any()]
          | map()
          | nil
  def clean_any_value(value, opts \\ [])

  def clean_any_value(%Opamp.Proto.AnyValue{value: {:string_value, value}}, _opts), do: value

  def clean_any_value(%Opamp.Proto.AnyValue{value: {:bool_value, value}}, opts) do
    case Keyword.get(opts, :cast_string, false) do
      true -> to_string(value)
      false -> value
    end
  end

  def clean_any_value(%Opamp.Proto.AnyValue{value: {:int_value, value}}, _opts), do: value
  def clean_any_value(%Opamp.Proto.AnyValue{value: {:double_value, value}}, _opts), do: value

  def clean_any_value(
        %Opamp.Proto.AnyValue{
          value: {:array_value, %Opamp.Proto.ArrayValue{values: values}}
        },
        opts
      ) do
    Enum.map(values, &clean_any_value(&1, opts))
  end

  def clean_any_value(
        %Opamp.Proto.AnyValue{
          value: {:kvlist_value, %Opamp.Proto.KeyValueList{values: kv_values}}
        },
        opts
      ) do
    Enum.reduce(kv_values, %{}, fn %Opamp.Proto.KeyValue{key: key, value: value}, acc ->
      Map.put(acc, key, clean_any_value(value, opts))
    end)
  end

  def clean_any_value(%Opamp.Proto.AnyValue{value: {:bytes_value, value}}, _opts),
    do: Base.encode64(value)

  def clean_any_value(_, _), do: nil

  def server_capabilities do
    [
      :ServerCapabilities_AcceptsStatus,
      :ServerCapabilities_OffersRemoteConfig,
      :ServerCapabilities_AcceptsEffectiveConfig,
      :ServerCapabilities_OffersConnectionSettings,
      :ServerCapabilities_AcceptsConnectionSettingsRequest
    ]
    |> Enum.map(&server_capability_to_int/1)
    |> Enum.reduce(&bor/2)
  end

  @spec server_flags_to_int(atom()) :: integer()
  def server_flags_to_int(flag) do
    case flag do
      :ServerToAgentFlags_Unspecified -> 0
      :ServerToAgentFlags_ReportFullState -> 1
      :ServerToAgentFlags_ReportAvailableComponents -> 2
      _ -> 0
    end
  end

  defp server_capability_to_int(capability) do
    case capability do
      :ServerCapabilities_Unspecified -> 0
      :ServerCapabilities_AcceptsStatus -> 0x00000001
      :ServerCapabilities_OffersRemoteConfig -> 0x00000002
      :ServerCapabilities_AcceptsEffectiveConfig -> 0x00000004
      :ServerCapabilities_OffersPackages -> 0x00000008
      :ServerCapabilities_AcceptsPackagesStatus -> 0x00000010
      :ServerCapabilities_OffersConnectionSettings -> 0x00000020
      :ServerCapabilities_AcceptsConnectionSettingsRequest -> 0x00000040
      _ -> 0
    end
  end

  def agent_has_capability?(agent_to_server, requested_capability) do
    case Map.get(agent_to_server, :capabilities) do
      nil ->
        false

      capabilities when is_integer(capabilities) ->
        (capabilities &&& agent_capability_to_int(requested_capability)) != 0

      _ ->
        false
    end
  end

  def agent_capability_to_int(capability) do
    case capability do
      :AgentCapabilities_Unspecified -> 0
      :AgentCapabilities_ReportsStatus -> 0x00000001
      :AgentCapabilities_AcceptsRemoteConfig -> 0x00000002
      :AgentCapabilities_ReportsEffectiveConfig -> 0x00000004
      :AgentCapabilities_AcceptsPackages -> 0x00000008
      :AgentCapabilities_ReportsPackageStatuses -> 0x00000010
      :AgentCapabilities_ReportsOwnTraces -> 0x00000020
      :AgentCapabilities_ReportsOwnMetrics -> 0x00000040
      :AgentCapabilities_ReportsOwnLogs -> 0x00000080
      :AgentCapabilities_AcceptsOpAMPConnectionSettings -> 0x00000100
      :AgentCapabilities_AcceptsOtherConnectionSettings -> 0x00000200
      :AgentCapabilities_AcceptsRestartCommand -> 0x00000400
      :AgentCapabilities_ReportsHealth -> 0x00000800
      :AgentCapabilities_ReportsRemoteConfig -> 0x00001000
      :AgentCapabilities_ReportsHeartbeat -> 0x00002000
      :AgentCapabilities_ReportsAvailableComponents -> 0x00004000
      :AgentCapabilities_ReportsConnectionSettingsStatus -> 0x00008000
      _ -> 0
    end
  end
end
