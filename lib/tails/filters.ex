defmodule Tails.Filters do
  alias Tails.Telemetry

  def get_records(stream_name, message, filters, resource_filters) do
    message.data[resource_accessor(stream_name)]
    |> Enum.reduce([], fn resourceRecord, resourceAcc ->
      case keep_record?(resourceRecord["resource"], resource_filters) do
        {true, _} -> resourceAcc ++ flatten_records(resourceRecord, stream_name, filters)
        {false, _} -> resourceAcc
      end
    end)
  end

  defp flatten_records(resourceRecord, stream_name, filters) do
    resourceRecord[scope_accessor(stream_name)]
    |> Enum.flat_map(fn scopeRecord ->
      scopeRecord[record_accessor(stream_name)]
      |> Enum.reduce([], fn item, acc ->
        item
        |> Map.put_new(:id, UUID.uuid4())
        |> normalize()
        |> Map.put_new("resource", Map.get(resourceRecord["resource"], "attributes", []))
        |> keep_record?(filters)
        |> append_record?(acc)
      end)
    end)
  end

  def keep_attributes?(attributes, filters) do
    initial_state = {contains_action(filters, :include), contains_action(filters, :exclude)}

    attributes
    |> cartesian(filters)
    |> Enum.reduce(initial_state, fn {attribute, {key, filter}}, current_state ->
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

  defp contains_action(filters, action) do
    Enum.reduce_while(filters, :empty, fn filter, acc ->
      {_, {filter_action, _}} = filter

      cond do
        filter_action == action ->
          {:halt, :nomatch}

        true ->
          {:cont, acc}
      end
    end)
  end

  defp append_record?({true, record}, acc), do: acc ++ [record]
  defp append_record?({false, _record}, acc), do: acc

  defp keep_record?(%{"attributes" => attrs} = record, filters),
    do: {keep_attributes?(attrs, filters), record}

  defp keep_record?(%{} = record, filters),
    do: {keep_attributes?([], filters), record}

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
    {action, Regex.match?(Regex.compile!("^#{value_regex}$"), Telemetry.string_from_value(value))}
  end

  defp normalize(%{"histogram" => %{"dataPoints" => data_points}} = data),
    do: Map.put(data, "attributes", get_attributes_from_metric(data_points))

  defp normalize(%{"gauge" => %{"dataPoints" => data_points}} = data),
    do: Map.put(data, "attributes", get_attributes_from_metric(data_points))

  defp normalize(%{"sum" => %{"dataPoints" => data_points}} = data),
    do: Map.put(data, "attributes", get_attributes_from_metric(data_points))

  defp normalize(data), do: data

  defp get_attributes_from_metric(data_points) do
    data_points
    |> Enum.reduce([], fn point, acc -> Map.get(point, "attributes", []) ++ acc end)
  end

  defp resource_accessor(stream_name),
    do: "resource#{String.capitalize(Atom.to_string(stream_name))}"

  defp scope_accessor(stream_name), do: "scope#{String.capitalize(Atom.to_string(stream_name))}"
  defp record_accessor(:logs), do: "logRecords"
  defp record_accessor(stream_name), do: Atom.to_string(stream_name)
end
