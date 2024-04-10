defmodule Tails.FiltersTest do
  use TailsWeb.TelemetryCase

  @test_attr %{"key" => "test", "value" => %{"stringValue" => "test"}}
  @example_attr %{"key" => "example", "value" => %{"stringValue" => "test"}}
  @include_test_filter {"test", {:include, ".*"}}
  @include_test_filter_bad_value {"test", {:include, "not"}}
  @exclude_test_filter {"test", {:exclude, ".*"}}
  @exclude_test_filter_bad_value {"test", {:exclude, "not"}}
  @nomatch_include_test_filter {"nothing", {:include, ".*"}}
  @nomatch_exclude_test_filter {"nothing", {:exclude, ".*"}}

  test "cartesian 1x0" do
    result = Tails.Filters.cartesian([@test_attr], [])
    assert Enum.to_list(result) == []
  end

  test "cartesian 0x1" do
    result = Tails.Filters.cartesian([], [@include_test_filter])
    assert Enum.to_list(result) == []
  end

  test "cartesian 1x1" do
    result = Tails.Filters.cartesian([@test_attr], [@include_test_filter])
    assert Enum.to_list(result) == [{@test_attr, @include_test_filter}]
  end

  test "cartesian 1x2" do
    result = Tails.Filters.cartesian([@test_attr], [@include_test_filter, @exclude_test_filter])

    assert Enum.to_list(result) == [
             {@test_attr, @include_test_filter},
             {@test_attr, @exclude_test_filter}
           ]
  end

  test "cartesian 2x2" do
    result =
      Tails.Filters.cartesian([@test_attr, @example_attr], [
        @include_test_filter,
        @exclude_test_filter
      ])

    assert Enum.to_list(result) == [
             {@test_attr, @include_test_filter},
             {@test_attr, @exclude_test_filter},
             {@example_attr, @include_test_filter},
             {@example_attr, @exclude_test_filter}
           ]
  end

  test "keep_attributes? no attrs exclude filters is true" do
    assert Tails.Filters.keep_attributes?([], [@exclude_test_filter]) == true
  end

  test "keep_attributes? no attrs include filters is false" do
    assert Tails.Filters.keep_attributes?([], [@include_test_filter]) == false
  end

  test "keep_attributes? no filters is true" do
    assert Tails.Filters.keep_attributes?([@test_attr], []) == true
  end

  test "keep_attributes? matches include is true" do
    assert Tails.Filters.keep_attributes?([@test_attr], [@include_test_filter]) == true
  end

  test "keep_attributes? matches exclude is false" do
    assert Tails.Filters.keep_attributes?([@test_attr], [@exclude_test_filter]) == false
  end

  test "keep_attributes? no matches include is false" do
    assert Tails.Filters.keep_attributes?([@test_attr], [@nomatch_include_test_filter]) == false
  end

  test "keep_attributes? no matches exclude is true" do
    assert Tails.Filters.keep_attributes?([@test_attr], [@nomatch_exclude_test_filter]) == true
  end

  test "keep_attributes? one include match is true" do
    assert Tails.Filters.keep_attributes?([@test_attr, @example_attr], [@include_test_filter]) ==
             true
  end

  test "keep_attributes? no include match is false" do
    assert Tails.Filters.keep_attributes?(
             [@test_attr, @example_attr],
             [@nomatch_include_test_filter]
           ) == false
  end

  test "keep_attributes? one exclude match is false" do
    assert Tails.Filters.keep_attributes?([@test_attr, @example_attr], [@exclude_test_filter]) ==
             false
  end

  test "keep_attributes? no exclude match is true" do
    assert Tails.Filters.keep_attributes?(
             [@test_attr, @example_attr],
             [@nomatch_exclude_test_filter]
           ) == true
  end

  test "keep_attributes? include match bad value" do
    assert Tails.Filters.keep_attributes?(
             [@test_attr],
             [@include_test_filter_bad_value]
           ) == false
  end

  test "keep_attributes? exclude match bad value" do
    assert Tails.Filters.keep_attributes?(
             [@test_attr],
             [@exclude_test_filter_bad_value]
           ) == true
  end

  test "keep_attributes? include match bad value previous include keep" do
    assert Tails.Filters.keep_attributes?(
             [@test_attr],
             [@include_test_filter, @include_test_filter_bad_value]
           ) == true
  end

  test "keep_attributes? exclude match bad value previous exclude toss" do
    assert Tails.Filters.keep_attributes?(
             [@test_attr],
             [@exclude_test_filter, @exclude_test_filter_bad_value]
           ) == false
  end

  test "get_records span empty data", %{empty_message: empty_message} do
    records = Tails.Filters.get_records(:spans, empty_message, [], [])
    assert length(records) == 0
  end

  test "get_records span no filters", %{span_message: span_message} do
    records = Tails.Filters.get_records(:spans, span_message, [], [])
    assert length(records) == 1
    %{:id => id, "attributes" => attrs, "resource" => resource} = List.first(records)

    assert String.length(id) > 0

    assert attrs == [
             %{"key" => "net.peer.ip", "value" => %{"stringValue" => "1.2.3.4"}},
             %{"key" => "os.kernel", "value" => %{"stringValue" => "23.3.0"}},
             %{"key" => "test", "value" => %{"stringValue" => "another"}}
           ]

    assert resource == [
             %{"key" => "test", "value" => %{"stringValue" => "something"}}
           ]
  end

  test "get_records log exclude resource attr filter", %{log_message: log_message} do
    records = Tails.Filters.get_records(:logs, log_message, [], [@exclude_test_filter])
    assert length(records) == 0
  end

  test "get_records log include attr filter", %{log_message: log_message} do
    records = Tails.Filters.get_records(:logs, log_message, [], [@include_test_filter])
    assert length(records) == 2
  end

  test "get_records span exclude attr filter", %{span_message: span_message} do
    records = Tails.Filters.get_records(:spans, span_message, [@exclude_test_filter], [])
    assert length(records) == 0
  end

  test "get_records span exclude resource attr filter", %{span_message: span_message} do
    records = Tails.Filters.get_records(:spans, span_message, [], [@exclude_test_filter])
    assert length(records) == 0
  end

  test "get_records span include attr filter", %{span_message: span_message} do
    records = Tails.Filters.get_records(:spans, span_message, [@include_test_filter], [])
    assert length(records) == 1
  end

  test "get_records span include resource attr filter", %{span_message: span_message} do
    records = Tails.Filters.get_records(:spans, span_message, [], [@include_test_filter])
    assert length(records) == 1
  end

  test "get_records multi span", %{multi_span_message: multi_span_message} do
    records = Tails.Filters.get_records(:spans, multi_span_message, [], [])
    assert length(records) == 2
    assert List.first(records)["name"] == "send data to the server 222"
    assert Enum.at(records, 1)["name"] == "send data to the server 223"
  end

  test "get_records multi span no include filter match", %{multi_span_message: multi_span_message} do
    records =
      Tails.Filters.get_records(:spans, multi_span_message, [@nomatch_include_test_filter], [])

    assert length(records) == 0
  end

  test "get_records multi span no exclude filter match", %{multi_span_message: multi_span_message} do
    records =
      Tails.Filters.get_records(:spans, multi_span_message, [@nomatch_exclude_test_filter], [])

    assert length(records) == 2
  end

  test "get_records multi span no include resource filter match", %{
    multi_span_message: multi_span_message
  } do
    records =
      Tails.Filters.get_records(:spans, multi_span_message, [], [@nomatch_include_test_filter])

    assert length(records) == 0
  end

  test "get_records multi span no exclude resource filter match", %{
    multi_span_message: multi_span_message
  } do
    records =
      Tails.Filters.get_records(:spans, multi_span_message, [], [@nomatch_exclude_test_filter])

    assert length(records) == 2
  end

  test "get_records multi span filters only one", %{multi_span_message: multi_span_message} do
    records = Tails.Filters.get_records(:spans, multi_span_message, [@exclude_test_filter], [])
    assert length(records) == 1
    assert List.first(records)["name"] == "send data to the server 223"
  end

  test "get_records multi span resource filters both", %{multi_span_message: multi_span_message} do
    records = Tails.Filters.get_records(:spans, multi_span_message, [], [@exclude_test_filter])
    assert length(records) == 0
  end

  test "get_records metric no filters", %{metric_message: metric_message} do
    records = Tails.Filters.get_records(:metrics, metric_message, [], [])
    assert length(records) == 3
  end

  test "get_records metric include filters keep", %{metric_message: metric_message} do
    records = Tails.Filters.get_records(:metrics, metric_message, [@include_test_filter], [])
    assert length(records) == 1
  end

  test "get_records metric exclude filters toss", %{metric_message: metric_message} do
    records = Tails.Filters.get_records(:metrics, metric_message, [@exclude_test_filter], [])
    assert length(records) == 2
  end

  test "get_records metric include no match filters toss", %{metric_message: metric_message} do
    records =
      Tails.Filters.get_records(:metrics, metric_message, [@nomatch_exclude_test_filter], [])

    assert length(records) == 3
  end

  test "get_records metric exclude no match filters keep", %{metric_message: metric_message} do
    records =
      Tails.Filters.get_records(:metrics, metric_message, [@nomatch_include_test_filter], [])

    assert length(records) == 0
  end

  test "get_records metric include resource filters keep", %{metric_message: metric_message} do
    records = Tails.Filters.get_records(:metrics, metric_message, [], [@include_test_filter])
    assert length(records) == 3
  end

  test "get_records metric exclude resource filters toss", %{metric_message: metric_message} do
    records = Tails.Filters.get_records(:metrics, metric_message, [], [@exclude_test_filter])
    assert length(records) == 0
  end

  test "get_records metric include no match resource filters keep", %{
    metric_message: metric_message
  } do
    records =
      Tails.Filters.get_records(:metrics, metric_message, [], [@nomatch_exclude_test_filter])

    assert length(records) == 3
  end

  test "get_records metric exclude no match resource filters toss", %{
    metric_message: metric_message
  } do
    records =
      Tails.Filters.get_records(:metrics, metric_message, [], [@nomatch_include_test_filter])

    assert length(records) == 0
  end

  test "get_records metric one filter include one resource exclude no match keeps some", %{
    metric_message: metric_message
  } do
    records =
      Tails.Filters.get_records(:metrics, metric_message, [@include_test_filter], [
        @nomatch_exclude_test_filter
      ])

    assert length(records) == 1
  end

  test "get_records metric one resource include one filter exclude no match keeps some", %{
    metric_message: metric_message
  } do
    records =
      Tails.Filters.get_records(:metrics, metric_message, [@nomatch_exclude_test_filter], [
        @include_test_filter
      ])

    assert length(records) == 3
  end

  test "get_records metric multiple filters one exclude one include", %{
    metric_message: metric_message
  } do
    records =
      Tails.Filters.get_records(
        :metrics,
        metric_message,
        [@exclude_test_filter, @nomatch_include_test_filter],
        []
      )

    assert length(records) == 2
  end
end
