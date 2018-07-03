defmodule MMDB2Decoder.LookupTree do
  @moduledoc """
  Locates IPs in the lookup tree.
  """

  use Bitwise, only_operators: true

  require Logger

  alias MMDB2Decoder.Metadata

  @doc """
  Locates the data pointer associated for a given IP.
  """
  @spec locate(tuple, Metadata.t(), binary) :: non_neg_integer
  def locate({0, 0, 0, 0, 0, 65535, a, b}, meta, tree) do
    locate({a >>> 8, a &&& 0x00FF, b >>> 8, b &&& 0x00FF}, meta, tree)
  end

  def locate({a, b, c, d}, %{ip_version: 6} = meta, tree) do
    <<a::size(8), b::size(8), c::size(8), d::size(8)>>
    |> traverse(0, 32, 96, meta, tree)
  end

  def locate({a, b, c, d}, meta, tree) do
    <<a::size(8), b::size(8), c::size(8), d::size(8)>>
    |> traverse(0, 32, 0, meta, tree)
  end

  def locate({_, _, _, _, _, _, _, _}, %{ip_version: 4}, _), do: 0

  def locate({a, b, c, d, e, f, g, h}, meta, tree) do
    <<
      a::size(16),
      b::size(16),
      c::size(16),
      d::size(16),
      e::size(16),
      f::size(16),
      g::size(16),
      h::size(16)
    >>
    |> traverse(0, 128, 0, meta, tree)
  end

  defp traverse(
         <<node_bit::size(1), rest::bitstring>>,
         bit,
         bit_count,
         node,
         %{node_count: node_count} = meta,
         tree
       )
       when bit < bit_count and node < node_count do
    node = read_node(node, node_bit, meta, tree)

    traverse(rest, bit + 1, bit_count, node, meta, tree)
  end

  defp traverse(_, bit, bit_count, node, %{node_count: node_count} = meta, _)
       when bit < bit_count and node >= node_count do
    traverse(nil, nil, nil, node, meta, nil)
  end

  defp traverse(_, _, _, node, %{node_count: node_count}, _)
       when node > node_count,
       do: node

  defp traverse(_, _, _, node, %{node_count: node_count}, _)
       when node == node_count,
       do: 0

  defp traverse(_, _, _, node, _, _) do
    Logger.error("Invalid node below node_count: #{node}")
    0
  end

  defp read_node(node, index, %{record_size: record_size}, tree) do
    record_half = rem(record_size, 8)
    record_left = record_size - record_half

    node_start = div(node * record_size, 4)
    node_len = div(record_size, 4)
    node_part = binary_part(tree, node_start, node_len)

    <<low::size(record_left), high::size(record_half), right::size(record_size)>> = node_part

    case index do
      0 -> low + (high <<< record_left)
      1 -> right
    end
  end
end
