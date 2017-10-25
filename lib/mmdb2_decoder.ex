defmodule MMDB2Decoder do
  @moduledoc """
  MMDB2 file format decoder.
  """

  alias MMDB2Decoder.Data
  alias MMDB2Decoder.LookupTree
  alias MMDB2Decoder.Metadata

  @metadata_marker <<0xAB, 0xCD, 0xEF>> <> "MaxMind.com"

  @doc """
  Looks up the data associated with an IP tuple.
  """
  @spec lookup(tuple, Metadata.t(), binary, binary) :: map | nil
  def lookup(ip, meta, tree, data) do
    ip
    |> LookupTree.locate(meta, tree)
    |> lookup_pointer(data, meta.node_count)
  end

  @doc """
  Parses a database binary and splits it into metadata, lookup tree and data.
  """
  @spec parse_database(binary) ::
          {Metadata.t(), binary, binary}
          | {:error, term}
  def parse_database(contents) do
    contents
    |> :binary.split(@metadata_marker)
    |> split_data()
  end

  defp lookup_pointer(0, _, _), do: nil

  defp lookup_pointer(ptr, data, node_count) do
    offset = ptr - node_count - 16

    case Data.value(data, offset) do
      result when is_map(result) -> result
      _ -> nil
    end
  end

  defp split_data([_]), do: {:error, :no_metadata}

  defp split_data([data, meta]) do
    meta = Data.value(meta, 0)
    meta = struct(%Metadata{}, meta)
    record_size = Map.get(meta, :record_size)
    node_count = Map.get(meta, :node_count)
    node_byte_size = div(record_size, 4)
    tree_size = node_count * node_byte_size

    meta = %{meta | node_byte_size: node_byte_size}
    meta = %{meta | tree_size: tree_size}

    tree = data |> binary_part(0, tree_size)
    data_size = byte_size(data) - byte_size(tree) - 16
    data = data |> binary_part(tree_size + 16, data_size)

    {meta, tree, data}
  end
end
