defmodule Tails.FiltersTest do
  use ExUnit.Case

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

  test "keep_record no filters is true" do
    assert Tails.Filters.keep_record([@test_attr], []) == true
  end

  test "keep_record matches include is true" do
    assert Tails.Filters.keep_record([@test_attr], [@include_test_filter]) == true
  end

  test "keep_record matches exclude is false" do
    assert Tails.Filters.keep_record([@test_attr], [@exclude_test_filter]) == false
  end

  test "keep_record no matches include is false" do
    assert Tails.Filters.keep_record([@test_attr], [@nomatch_include_test_filter]) == false
  end

  test "keep_record no matches exclude is true" do
    assert Tails.Filters.keep_record([@test_attr], [@nomatch_exclude_test_filter]) == true
  end

  test "keep_record one include match is true" do
    assert Tails.Filters.keep_record([@test_attr, @example_attr], [@include_test_filter]) == true
  end

  test "keep_record no include match is false" do
    assert Tails.Filters.keep_record(
             [@test_attr, @example_attr],
             [@nomatch_include_test_filter]
           ) == false
  end

  test "keep_record one exclude match is false" do
    assert Tails.Filters.keep_record([@test_attr, @example_attr], [@exclude_test_filter]) == false
  end

  test "keep_record no exclude match is true" do
    assert Tails.Filters.keep_record(
             [@test_attr, @example_attr],
             [@nomatch_exclude_test_filter]
           ) == true
  end
end
