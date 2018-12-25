defmodule MMDB2Decoder.LookupTree do
  @moduledoc false

  use Bitwise, only_operators: true

  alias MMDB2Decoder.Metadata

  @doc """
  Locates the data pointer associated for a given IP.
  """
  @spec locate(tuple, Metadata.t(), binary) :: {:ok, non_neg_integer} | {:error, term}
  def locate(
        {a, b, c, d},
        %{ip_version: 6, node_count: node_count, record_size: record_size},
        tree
      ) do
    traverse(
      <<a::size(8), b::size(8), c::size(8), d::size(8)>>,
      96,
      node_count,
      record_size,
      tree
    )
  end

  def locate(
        {a, b, c, d},
        %{node_count: node_count, record_size: record_size},
        tree
      ) do
    traverse(<<a::size(8), b::size(8), c::size(8), d::size(8)>>, 0, node_count, record_size, tree)
  end

  def locate({0, 0, 0, 0, 0, 65_535, a, b}, meta, tree) do
    locate({a >>> 8, a &&& 0x00FF, b >>> 8, b &&& 0x00FF}, meta, tree)
  end

  def locate({_, _, _, _, _, _, _, _}, %{ip_version: 4}, _), do: {:ok, 0}

  def locate(
        {a, b, c, d, e, f, g, h},
        %{node_count: node_count, record_size: record_size},
        tree
      ) do
    traverse(
      <<
        a::size(16),
        b::size(16),
        c::size(16),
        d::size(16),
        e::size(16),
        f::size(16),
        g::size(16),
        h::size(16)
      >>,
      0,
      node_count,
      record_size,
      tree
    )
  end

  defp traverse(
         <<node_bit::size(1), rest::bitstring>>,
         node,
         node_count,
         record_size,
         tree
       )
       when node < node_count do
    traverse(
      rest,
      read_node(node, node_bit, record_size, tree),
      node_count,
      record_size,
      tree
    )
  end

  defp traverse(_, node, node_count, _, _)
       when node > node_count,
       do: {:ok, node}

  defp traverse(_, node, node_count, _, _)
       when node == node_count,
       do: {:ok, 0}

  defp traverse(_, node, node_count, _, _)
       when node < node_count,
       do: {:error, :node_below_count}

  defp read_node(node, index, record_size, tree) do
    node_start = div(node * record_size, 4)
    node_len = div(record_size, 4)
    node_part = binary_part(tree, node_start, node_len)

    case index do
      0 ->
        record_half = rem(record_size, 8)
        record_left = record_size - record_half

        <<low::size(record_left), high::size(record_half), _::bitstring>> = node_part

        low + (high <<< record_left)

      1 ->
        <<_::size(record_size), right::size(record_size)>> = node_part
        right
    end
  end
end
