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
        %{ip_version: 6} = meta,
        tree
      ) do
    do_locate(<<a::size(8), b::size(8), c::size(8), d::size(8)>>, 96, meta, tree)
  end

  def locate({a, b, c, d}, meta, tree) do
    do_locate(<<a::size(8), b::size(8), c::size(8), d::size(8)>>, 0, meta, tree)
  end

  def locate({0, 0, 0, 0, 0, 65_535, a, b}, meta, tree) do
    locate({a >>> 8, a &&& 0x00FF, b >>> 8, b &&& 0x00FF}, meta, tree)
  end

  def locate({_, _, _, _, _, _, _, _}, %{ip_version: 4}, _), do: {:ok, 0}

  def locate({a, b, c, d, e, f, g, h}, meta, tree) do
    do_locate(
      <<a::size(16), b::size(16), c::size(16), d::size(16), e::size(16), f::size(16), g::size(16),
        h::size(16)>>,
      0,
      meta,
      tree
    )
  end

  defp do_locate(
         address,
         node,
         %{node_byte_size: node_size, node_count: node_count, record_size: record_size},
         tree
       ) do
    traverse(address, node, node_count, node_size, record_size, tree)
  end

  defp traverse(
         <<0::size(1), rest::bitstring>>,
         node,
         node_count,
         node_size,
         28 = record_size,
         tree
       )
       when node < node_count do
    node_start = node * node_size

    <<_::size(node_start)-binary, low::size(24), high::size(4), _::bitstring>> = tree

    node_next = low + (high <<< 24)

    traverse(rest, node_next, node_count, node_size, record_size, tree)
  end

  defp traverse(
         <<0::size(1), rest::bitstring>>,
         node,
         node_count,
         node_size,
         record_size,
         tree
       )
       when node < node_count do
    node_start = node * node_size

    <<_::size(node_start)-binary, node_next::size(record_size), _::bitstring>> = tree

    traverse(rest, node_next, node_count, node_size, record_size, tree)
  end

  defp traverse(
         <<1::size(1), rest::bitstring>>,
         node,
         node_count,
         node_size,
         record_size,
         tree
       )
       when node < node_count do
    node_start = node * node_size

    <<_::size(node_start)-binary, _::size(record_size), node_next::size(record_size),
      _::bitstring>> = tree

    traverse(rest, node_next, node_count, node_size, record_size, tree)
  end

  defp traverse(_, node, node_count, _, _, _)
       when node >= node_count,
       do: {:ok, node}

  defp traverse(_, node, node_count, _, _, _)
       when node < node_count,
       do: {:error, :node_below_count}
end
