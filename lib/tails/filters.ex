defmodule Tails.Filters do
  alias Tails.Telemetry

  def keep_record(attributes, filters) do
    attributes
    |> cartesian(filters)
    |> Enum.reduce({:empty, :empty}, fn {attribute, {key, filter}}, current_state ->
      cond do
        attribute["key"] == key ->
          apply_filter(attribute["value"], filter) |> next_state(current_state, true)

        attribute["key"] != key ->
          apply_no_key_match(filter) |> next_state(current_state, false)

        true ->
          current_state
      end
    end)
    |> should_keep()
  end

  def cartesian(attributes, filters) do
    Stream.flat_map(attributes, fn attribute ->
      Stream.map(filters, fn filter ->
        {attribute, filter}
      end)
    end)
  end

  defp apply_no_key_match({:include, _filter}), do: {:include, false}
  defp apply_no_key_match({:exclude, _filter}), do: {:exclude, false}
  defp next_state({:include, true}, {_inclusion, exclusion}, true), do: {:match, exclusion}
  defp next_state({:include, false}, {:match, exclusion}, true), do: {:match, exclusion}
  defp next_state({:include, false}, {_inclusion, exclusion}, true), do: {:nomatch, exclusion}
  defp next_state({:exclude, true}, {inclusion, _exclusion}, true), do: {inclusion, :match}
  defp next_state({:exclude, false}, {inclusion, :match}, true), do: {inclusion, :match}
  defp next_state({:exclude, false}, {inclusion, _exclusion}, true), do: {inclusion, :nomatch}
  defp next_state({:include, _}, {:match, exclusion}, false), do: {:match, exclusion}
  defp next_state({:include, _}, {_inclusion, exclusion}, false), do: {:nomatch, exclusion}
  defp next_state({:exclude, _}, {inclusion, :match}, false), do: {inclusion, :match}
  defp next_state({:exclude, _}, {inclusion, _exclusion}, false), do: {inclusion, :nomatch}
  defp next_state(_filter_result, current_state, _key_match), do: current_state

  defp should_keep({_, :match}), do: false
  defp should_keep({:match, _}), do: true
  defp should_keep({:nomatch, :empty}), do: false
  defp should_keep({:empty, :nomatch}), do: true
  defp should_keep({:empty, :empty}), do: true
  defp should_keep(_), do: true

  defp apply_filter(value, filter) do
    {action, value_regex} = filter
    {action, Regex.match?(Regex.compile!(value_regex), Telemetry.string_from_value(value))}
  end
end
