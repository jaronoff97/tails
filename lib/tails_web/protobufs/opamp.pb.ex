defmodule Opamp.Proto.AgentToServerFlags do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :AgentToServerFlags_Unspecified, 0
  field :AgentToServerFlags_RequestInstanceUid, 1
end

defmodule Opamp.Proto.ServerToAgentFlags do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :ServerToAgentFlags_Unspecified, 0
  field :ServerToAgentFlags_ReportFullState, 1
end

defmodule Opamp.Proto.ServerCapabilities do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :ServerCapabilities_Unspecified, 0
  field :ServerCapabilities_AcceptsStatus, 1
  field :ServerCapabilities_OffersRemoteConfig, 2
  field :ServerCapabilities_AcceptsEffectiveConfig, 4
  field :ServerCapabilities_OffersPackages, 8
  field :ServerCapabilities_AcceptsPackagesStatus, 16
  field :ServerCapabilities_OffersConnectionSettings, 32
  field :ServerCapabilities_AcceptsConnectionSettingsRequest, 64
end

defmodule Opamp.Proto.PackageType do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :PackageType_TopLevel, 0
  field :PackageType_Addon, 1
end

defmodule Opamp.Proto.ServerErrorResponseType do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :ServerErrorResponseType_Unknown, 0
  field :ServerErrorResponseType_BadRequest, 1
  field :ServerErrorResponseType_Unavailable, 2
end

defmodule Opamp.Proto.CommandType do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :CommandType_Restart, 0
end

defmodule Opamp.Proto.AgentCapabilities do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :AgentCapabilities_Unspecified, 0
  field :AgentCapabilities_ReportsStatus, 1
  field :AgentCapabilities_AcceptsRemoteConfig, 2
  field :AgentCapabilities_ReportsEffectiveConfig, 4
  field :AgentCapabilities_AcceptsPackages, 8
  field :AgentCapabilities_ReportsPackageStatuses, 16
  field :AgentCapabilities_ReportsOwnTraces, 32
  field :AgentCapabilities_ReportsOwnMetrics, 64
  field :AgentCapabilities_ReportsOwnLogs, 128
  field :AgentCapabilities_AcceptsOpAMPConnectionSettings, 256
  field :AgentCapabilities_AcceptsOtherConnectionSettings, 512
  field :AgentCapabilities_AcceptsRestartCommand, 1024
  field :AgentCapabilities_ReportsHealth, 2048
  field :AgentCapabilities_ReportsRemoteConfig, 4096
end

defmodule Opamp.Proto.RemoteConfigStatuses do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :RemoteConfigStatuses_UNSET, 0
  field :RemoteConfigStatuses_APPLIED, 1
  field :RemoteConfigStatuses_APPLYING, 2
  field :RemoteConfigStatuses_FAILED, 3
end

defmodule Opamp.Proto.PackageStatusEnum do
  @moduledoc false

  use Protobuf, enum: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :PackageStatusEnum_Installed, 0
  field :PackageStatusEnum_InstallPending, 1
  field :PackageStatusEnum_Installing, 2
  field :PackageStatusEnum_InstallFailed, 3
end

defmodule Opamp.Proto.AgentToServer do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :instance_uid, 1, type: :string, json_name: "instanceUid"
  field :sequence_num, 2, type: :uint64, json_name: "sequenceNum"
  field :agent_description, 3, type: Opamp.Proto.AgentDescription, json_name: "agentDescription"
  field :capabilities, 4, type: :uint64
  field :health, 5, type: Opamp.Proto.ComponentHealth
  field :effective_config, 6, type: Opamp.Proto.EffectiveConfig, json_name: "effectiveConfig"

  field :remote_config_status, 7,
    type: Opamp.Proto.RemoteConfigStatus,
    json_name: "remoteConfigStatus"

  field :package_statuses, 8, type: Opamp.Proto.PackageStatuses, json_name: "packageStatuses"
  field :agent_disconnect, 9, type: Opamp.Proto.AgentDisconnect, json_name: "agentDisconnect"
  field :flags, 10, type: :uint64

  field :connection_settings_request, 11,
    type: Opamp.Proto.ConnectionSettingsRequest,
    json_name: "connectionSettingsRequest"
end

defmodule Opamp.Proto.AgentDisconnect do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"
end

defmodule Opamp.Proto.ConnectionSettingsRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :opamp, 1, type: Opamp.Proto.OpAMPConnectionSettingsRequest
end

defmodule Opamp.Proto.OpAMPConnectionSettingsRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :certificate_request, 1,
    type: Opamp.Proto.CertificateRequest,
    json_name: "certificateRequest"
end

defmodule Opamp.Proto.CertificateRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :csr, 1, type: :bytes
end

defmodule Opamp.Proto.ServerToAgent do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :instance_uid, 1, type: :string, json_name: "instanceUid"
  field :error_response, 2, type: Opamp.Proto.ServerErrorResponse, json_name: "errorResponse"
  field :remote_config, 3, type: Opamp.Proto.AgentRemoteConfig, json_name: "remoteConfig"

  field :connection_settings, 4,
    type: Opamp.Proto.ConnectionSettingsOffers,
    json_name: "connectionSettings"

  field :packages_available, 5,
    type: Opamp.Proto.PackagesAvailable,
    json_name: "packagesAvailable"

  field :flags, 6, type: :uint64
  field :capabilities, 7, type: :uint64

  field :agent_identification, 8,
    type: Opamp.Proto.AgentIdentification,
    json_name: "agentIdentification"

  field :command, 9, type: Opamp.Proto.ServerToAgentCommand
end

defmodule Opamp.Proto.OpAMPConnectionSettings do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :destination_endpoint, 1, type: :string, json_name: "destinationEndpoint"
  field :headers, 2, type: Opamp.Proto.Headers
  field :certificate, 3, type: Opamp.Proto.TLSCertificate
end

defmodule Opamp.Proto.TelemetryConnectionSettings do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :destination_endpoint, 1, type: :string, json_name: "destinationEndpoint"
  field :headers, 2, type: Opamp.Proto.Headers
  field :certificate, 3, type: Opamp.Proto.TLSCertificate
end

defmodule Opamp.Proto.OtherConnectionSettings.OtherSettingsEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Opamp.Proto.OtherConnectionSettings do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :destination_endpoint, 1, type: :string, json_name: "destinationEndpoint"
  field :headers, 2, type: Opamp.Proto.Headers
  field :certificate, 3, type: Opamp.Proto.TLSCertificate

  field :other_settings, 4,
    repeated: true,
    type: Opamp.Proto.OtherConnectionSettings.OtherSettingsEntry,
    json_name: "otherSettings",
    map: true
end

defmodule Opamp.Proto.Headers do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :headers, 1, repeated: true, type: Opamp.Proto.Header
end

defmodule Opamp.Proto.Header do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :key, 1, type: :string
  field :value, 2, type: :string
end

defmodule Opamp.Proto.TLSCertificate do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :public_key, 1, type: :bytes, json_name: "publicKey"
  field :private_key, 2, type: :bytes, json_name: "privateKey"
  field :ca_public_key, 3, type: :bytes, json_name: "caPublicKey"
end

defmodule Opamp.Proto.ConnectionSettingsOffers.OtherConnectionsEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :key, 1, type: :string
  field :value, 2, type: Opamp.Proto.OtherConnectionSettings
end

defmodule Opamp.Proto.ConnectionSettingsOffers do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :hash, 1, type: :bytes
  field :opamp, 2, type: Opamp.Proto.OpAMPConnectionSettings
  field :own_metrics, 3, type: Opamp.Proto.TelemetryConnectionSettings, json_name: "ownMetrics"
  field :own_traces, 4, type: Opamp.Proto.TelemetryConnectionSettings, json_name: "ownTraces"
  field :own_logs, 5, type: Opamp.Proto.TelemetryConnectionSettings, json_name: "ownLogs"

  field :other_connections, 6,
    repeated: true,
    type: Opamp.Proto.ConnectionSettingsOffers.OtherConnectionsEntry,
    json_name: "otherConnections",
    map: true
end

defmodule Opamp.Proto.PackagesAvailable.PackagesEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :key, 1, type: :string
  field :value, 2, type: Opamp.Proto.PackageAvailable
end

defmodule Opamp.Proto.PackagesAvailable do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :packages, 1, repeated: true, type: Opamp.Proto.PackagesAvailable.PackagesEntry, map: true
  field :all_packages_hash, 2, type: :bytes, json_name: "allPackagesHash"
end

defmodule Opamp.Proto.PackageAvailable do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :type, 1, type: Opamp.Proto.PackageType, enum: true
  field :version, 2, type: :string
  field :file, 3, type: Opamp.Proto.DownloadableFile
  field :hash, 4, type: :bytes
end

defmodule Opamp.Proto.DownloadableFile do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :download_url, 1, type: :string, json_name: "downloadUrl"
  field :content_hash, 2, type: :bytes, json_name: "contentHash"
  field :signature, 3, type: :bytes
end

defmodule Opamp.Proto.ServerErrorResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  oneof :Details, 0

  field :type, 1, type: Opamp.Proto.ServerErrorResponseType, enum: true
  field :error_message, 2, type: :string, json_name: "errorMessage"
  field :retry_info, 3, type: Opamp.Proto.RetryInfo, json_name: "retryInfo", oneof: 0
end

defmodule Opamp.Proto.RetryInfo do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :retry_after_nanoseconds, 1, type: :uint64, json_name: "retryAfterNanoseconds"
end

defmodule Opamp.Proto.ServerToAgentCommand do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :type, 1, type: Opamp.Proto.CommandType, enum: true
end

defmodule Opamp.Proto.AgentDescription do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :identifying_attributes, 1,
    repeated: true,
    type: Opamp.Proto.KeyValue,
    json_name: "identifyingAttributes"

  field :non_identifying_attributes, 2,
    repeated: true,
    type: Opamp.Proto.KeyValue,
    json_name: "nonIdentifyingAttributes"
end

defmodule Opamp.Proto.ComponentHealth.ComponentHealthMapEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :key, 1, type: :string
  field :value, 2, type: Opamp.Proto.ComponentHealth
end

defmodule Opamp.Proto.ComponentHealth do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :healthy, 1, type: :bool
  field :start_time_unix_nano, 2, type: :fixed64, json_name: "startTimeUnixNano"
  field :last_error, 3, type: :string, json_name: "lastError"
  field :status, 4, type: :string
  field :status_time_unix_nano, 5, type: :fixed64, json_name: "statusTimeUnixNano"

  field :component_health_map, 6,
    repeated: true,
    type: Opamp.Proto.ComponentHealth.ComponentHealthMapEntry,
    json_name: "componentHealthMap",
    map: true
end

defmodule Opamp.Proto.EffectiveConfig do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :config_map, 1, type: Opamp.Proto.AgentConfigMap, json_name: "configMap"
end

defmodule Opamp.Proto.RemoteConfigStatus do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :last_remote_config_hash, 1, type: :bytes, json_name: "lastRemoteConfigHash"
  field :status, 2, type: Opamp.Proto.RemoteConfigStatuses, enum: true
  field :error_message, 3, type: :string, json_name: "errorMessage"
end

defmodule Opamp.Proto.PackageStatuses.PackagesEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :key, 1, type: :string
  field :value, 2, type: Opamp.Proto.PackageStatus
end

defmodule Opamp.Proto.PackageStatuses do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :packages, 1, repeated: true, type: Opamp.Proto.PackageStatuses.PackagesEntry, map: true

  field :server_provided_all_packages_hash, 2,
    type: :bytes,
    json_name: "serverProvidedAllPackagesHash"

  field :error_message, 3, type: :string, json_name: "errorMessage"
end

defmodule Opamp.Proto.PackageStatus do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :name, 1, type: :string
  field :agent_has_version, 2, type: :string, json_name: "agentHasVersion"
  field :agent_has_hash, 3, type: :bytes, json_name: "agentHasHash"
  field :server_offered_version, 4, type: :string, json_name: "serverOfferedVersion"
  field :server_offered_hash, 5, type: :bytes, json_name: "serverOfferedHash"
  field :status, 6, type: Opamp.Proto.PackageStatusEnum, enum: true
  field :error_message, 7, type: :string, json_name: "errorMessage"
end

defmodule Opamp.Proto.AgentIdentification do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :new_instance_uid, 1, type: :string, json_name: "newInstanceUid"
end

defmodule Opamp.Proto.AgentRemoteConfig do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :config, 1, type: Opamp.Proto.AgentConfigMap
  field :config_hash, 2, type: :bytes, json_name: "configHash"
end

defmodule Opamp.Proto.AgentConfigMap.ConfigMapEntry do
  @moduledoc false

  use Protobuf, map: true, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :key, 1, type: :string
  field :value, 2, type: Opamp.Proto.AgentConfigFile
end

defmodule Opamp.Proto.AgentConfigMap do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :config_map, 1,
    repeated: true,
    type: Opamp.Proto.AgentConfigMap.ConfigMapEntry,
    json_name: "configMap",
    map: true
end

defmodule Opamp.Proto.AgentConfigFile do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :body, 1, type: :bytes
  field :content_type, 2, type: :string, json_name: "contentType"
end
