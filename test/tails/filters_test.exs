defmodule Tails.FiltersTest do
  use TailsWeb.TelemetryCase

  @test_attr %{"key" => "test", "value" => %{"stringValue" => "test"}}
  @example_attr %{"key" => "example", "value" => %{"stringValue" => "test"}}
  @include_test_filter {"test", {:include, ".*"}}
  @exclude_test_filter {"test", {:exclude, ".*"}}
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

  test "get_records span exclude attr filter", %{span_message: span_message} do
    records = Tails.Filters.get_records(:spans, span_message, [@exclude_test_filter], [])
    assert length(records) == 0
  end

  test "get_records span exclude resource attr filter", %{span_message: span_message} do
    records = Tails.Filters.get_records(:spans, span_message, [], [@exclude_test_filter])
    assert length(records) == 0
  end
end
