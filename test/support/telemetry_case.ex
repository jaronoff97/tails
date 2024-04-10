defmodule TailsWeb.TelemetryCase do
  @moduledoc """
  This module defines the test case to be used by tests that require
  telemetry.

  TODO: use otel-erlang to generate data
  """
  alias Tails.Telemetry.Message
  use ExUnit.CaseTemplate

  setup _tags do
    %{
      empty_message: %Message{data: %{}, id: UUID.uuid4()},
      span_message: %Message{data: get_span(), id: UUID.uuid4()},
      log_message: %Message{data: get_log(), id: UUID.uuid4()},
      multi_span_message: %Message{data: get_multi_span(), id: UUID.uuid4()},
      metric_message: %Message{data: get_metric(), id: UUID.uuid4()}
    }
  end

  def get_log do
    %{
      "resourceLogs" => [
        %{
          "resource" => %{
            "attributes" => [
              %{
                "key" => "test",
                "value" => %{"stringValue" => "something"}
              }
            ]
          },
          "scopeLogs" => [
            %{
              "logRecords" => [
                %{
                  "attributes" => [
                    %{"key" => "app", "value" => %{"stringValue" => "server"}}
                  ],
                  "body" => %{"stringValue" => "the message"},
                  "droppedAttributesCount" => 1,
                  "severityNumber" => 9,
                  "severityText" => "Info",
                  "spanId" => "",
                  "timeUnixNano" => "1712714894685381000",
                  "traceId" => ""
                },
                %{
                  "body" => %{"stringValue" => "another message"},
                  "droppedAttributesCount" => 1,
                  "severityNumber" => 9,
                  "severityText" => "Info",
                  "spanId" => "",
                  "timeUnixNano" => "1712714894685381000",
                  "traceId" => ""
                }
              ],
              "scope" => %{}
            }
          ]
        }
      ]
    }
  end

  def get_multi_span do
    %{
      "resourceSpans" => [
        %{
          "resource" => %{
            "attributes" => [
              %{
                "key" => "test",
                "value" => %{"stringValue" => "something"}
              }
            ]
          },
          "schemaUrl" => "https://opentelemetry.io/schemas/1.17.0",
          "scopeSpans" => [
            %{
              "schemaUrl" => "https://opentelemetry.io/schemas/1.17.0",
              "scope" => %{
                "name" => "github.com/equinix-labs/otel-cli",
                "version" => "0.4.1 5f2c343fa859c07b885eaeedd8f06853c39e97a4 2023-10-17T14:14:45Z"
              },
              "spans" => [
                %{
                  "attributes" => [
                    %{
                      "key" => "net.peer.ip",
                      "value" => %{"stringValue" => "1.2.3.4"}
                    },
                    %{"key" => "os.kernel", "value" => %{"stringValue" => "23.3.0"}},
                    %{"key" => "test", "value" => %{"stringValue" => "another"}}
                  ],
                  "endTimeUnixNano" => "1712632442951009000",
                  "kind" => 3,
                  "name" => "send data to the server 222",
                  "parentSpanId" => "",
                  "spanId" => "f1f1935c4aa4bb3f",
                  "startTimeUnixNano" => "1712632442951009000",
                  "status" => %{},
                  "traceId" => "bb339f8aa22a9f0694ebf420e9a388f4"
                }
              ]
            },
            %{
              "schemaUrl" => "https://opentelemetry.io/schemas/1.17.0",
              "scope" => %{
                "name" => "github.com/equinix-labs/otel-cli",
                "version" => "0.4.1 5f2c343fa859c07b885eaeedd8f06853c39e97a4 2023-10-17T14:14:45Z"
              },
              "spans" => [
                %{
                  "attributes" => [
                    %{
                      "key" => "net.peer.ip",
                      "value" => %{"stringValue" => "1.2.3.4"}
                    },
                    %{"key" => "os.kernel", "value" => %{"stringValue" => "23.3.0"}},
                    %{"key" => "anothertest", "value" => %{"stringValue" => "another"}}
                  ],
                  "endTimeUnixNano" => "1712632442951009000",
                  "kind" => 3,
                  "name" => "send data to the server 223",
                  "parentSpanId" => "",
                  "spanId" => "f1f1935c4aa4bb3f",
                  "startTimeUnixNano" => "1712632442951009000",
                  "status" => %{},
                  "traceId" => "bb339f8aa22a9f0694ebf420e9a388f4"
                }
              ]
            }
          ]
        }
      ]
    }
  end

  def get_span do
    %{
      "resourceSpans" => [
        %{
          "resource" => %{
            "attributes" => [
              %{
                "key" => "test",
                "value" => %{"stringValue" => "something"}
              }
            ]
          },
          "schemaUrl" => "https://opentelemetry.io/schemas/1.17.0",
          "scopeSpans" => [
            %{
              "schemaUrl" => "https://opentelemetry.io/schemas/1.17.0",
              "scope" => %{
                "name" => "github.com/equinix-labs/otel-cli",
                "version" => "0.4.1 5f2c343fa859c07b885eaeedd8f06853c39e97a4 2023-10-17T14:14:45Z"
              },
              "spans" => [
                %{
                  "attributes" => [
                    %{
                      "key" => "net.peer.ip",
                      "value" => %{"stringValue" => "1.2.3.4"}
                    },
                    %{"key" => "os.kernel", "value" => %{"stringValue" => "23.3.0"}},
                    %{"key" => "test", "value" => %{"stringValue" => "another"}}
                  ],
                  "endTimeUnixNano" => "1712632442951009000",
                  "kind" => 3,
                  "name" => "send data to the server 222",
                  "parentSpanId" => "",
                  "spanId" => "f1f1935c4aa4bb3f",
                  "startTimeUnixNano" => "1712632442951009000",
                  "status" => %{},
                  "traceId" => "bb339f8aa22a9f0694ebf420e9a388f4"
                }
              ]
            }
          ]
        }
      ]
    }
  end

  def get_metric do
    %{
      "resourceMetrics" => [
        %{
          "resource" => %{
            "attributes" => [
              %{
                "key" => "test",
                "value" => %{"stringValue" => "something"}
              },
              %{
                "key" => "service.name",
                "value" => %{"stringValue" => "otel-collector"}
              },
              %{
                "key" => "service.instance.id",
                "value" => %{"stringValue" => "0.0.0.0:8888"}
              },
              %{"key" => "net.host.port", "value" => %{"stringValue" => "8888"}},
              %{"key" => "http.scheme", "value" => %{"stringValue" => "http"}},
              %{
                "key" => "service_instance_id",
                "value" => %{
                  "stringValue" => "fe30969d-02cc-4c15-aa42-9e167cf9051f"
                }
              },
              %{
                "key" => "service_name",
                "value" => %{"stringValue" => "otelcol-contrib"}
              },
              %{"key" => "service_version", "value" => %{"stringValue" => "0.97.0"}}
            ]
          },
          "scopeMetrics" => [
            %{
              "metrics" => [
                %{
                  "description" => "Number of metric points successfully sent to destination.",
                  "name" => "otelcol_exporter_sent_metric_points",
                  "sum" => %{
                    "aggregationTemporality" => 2,
                    "dataPoints" => [
                      %{
                        "asDouble" => 12471,
                        "attributes" => [
                          %{
                            "key" => "test",
                            "value" => %{"stringValue" => "something"}
                          },
                          %{
                            "key" => "exporter",
                            "value" => %{"stringValue" => "debug"}
                          },
                          %{
                            "key" => "service_instance_id",
                            "value" => %{
                              "stringValue" => "fe30969d-02cc-4c15-aa42-9e167cf9051f"
                            }
                          },
                          %{
                            "key" => "service_name",
                            "value" => %{"stringValue" => "otelcol-contrib"}
                          },
                          %{
                            "key" => "service_version",
                            "value" => %{"stringValue" => "0.97.0"}
                          }
                        ],
                        "startTimeUnixNano" => "1712626162283000000",
                        "timeUnixNano" => "1712632154894000000"
                      }
                    ],
                    "isMonotonic" => true
                  }
                },
                %{
                  "description" => "Measures size of RPC response messages (uncompressed).",
                  "histogram" => %{
                    "aggregationTemporality" => 2,
                    "dataPoints" => [
                      %{
                        "attributes" => [
                          %{"key" => "rpc_method", "value" => %{"stringValue" => "Export"}},
                          %{
                            "key" => "rpc_service",
                            "value" => %{
                              "stringValue" =>
                                "opentelemetry.proto.collector.trace.v1.TraceService"
                            }
                          },
                          %{"key" => "rpc_system", "value" => %{"stringValue" => "grpc"}},
                          %{
                            "key" => "service_instance_id",
                            "value" => %{"stringValue" => "fe30969d-02cc-4c15-aa42-9e167cf9051f"}
                          },
                          %{
                            "key" => "service_name",
                            "value" => %{"stringValue" => "otelcol-contrib"}
                          },
                          %{"key" => "service_version", "value" => %{"stringValue" => "0.97.0"}}
                        ],
                        "bucketCounts" => [
                          "0",
                          "4",
                          "0",
                          "0",
                          "0",
                          "0",
                          "0",
                          "0",
                          "0",
                          "0",
                          "0",
                          "0",
                          "0",
                          "0",
                          "0",
                          "0"
                        ],
                        "count" => "4",
                        "explicitBounds" => [
                          0,
                          5,
                          10,
                          25,
                          50,
                          75,
                          100,
                          250,
                          500,
                          750,
                          1000,
                          2500,
                          5000,
                          7500,
                          10000
                        ],
                        "startTimeUnixNano" => "1712632444894000000",
                        "sum" => 8,
                        "timeUnixNano" => "1712713350815000000"
                      }
                    ]
                  },
                  "id" => "fbdc4285-d6ca-457d-8a38-d4b6ce11c7f9",
                  "name" => "otelcol_rpc_server_response_size"
                },
                %{
                  "description" => "Duration of the scrape",
                  "gauge" => %{
                    "dataPoints" => [
                      %{
                        "asDouble" => 0.004100209,
                        "attributes" => [],
                        "timeUnixNano" => "1712713430816000000"
                      }
                    ]
                  },
                  "id" => "bbc46112-ba32-4bb7-b990-f67aad4bbfa0",
                  "name" => "scrape_duration_seconds",
                  "unit" => "s"
                }
              ],
              "scope" => %{
                "name" => "otelcol/prometheusreceiver",
                "version" => "0.97.0"
              }
            }
          ]
        }
      ]
    }
  end
end
