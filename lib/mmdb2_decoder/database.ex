defmodule MMDB2Decoder.Database do
  @moduledoc """
  Main level database logic.
  """

  alias MMDB2Decoder.Data
  alias MMDB2Decoder.Metadata

  @doc """
  Looks up a pointer in a database.
  """
  @spec lookup_pointer(non_neg_integer, binary, Metadata.t()) :: map | nil
  def lookup_pointer(0, _, _), do: nil

  def lookup_pointer(ptr, data, %{node_count: node_count}) do
    offset = ptr - node_count - 16

    case Data.value(data, offset) do
      result when is_map(result) -> result
      _ -> nil
    end
  end

  @doc """
  Splits the data part according to a metadata definition.
  """
  @spec split_data(binary, binary) :: {Metadata.t(), binary, binary}
  def split_data(meta, data) do
    meta = Data.value(meta, 0)
    meta = struct(%Metadata{}, meta)

    %{node_count: node_count, record_size: record_size} = meta

    node_byte_size = div(record_size, 4)
    tree_size = node_count * node_byte_size

    meta = %{meta | node_byte_size: node_byte_size}
    meta = %{meta | tree_size: tree_size}

    tree = binary_part(data, 0, tree_size)
    data_size = byte_size(data) - byte_size(tree) - 16
    data = binary_part(data, tree_size + 16, data_size)

    {meta, tree, data}
  end
end
