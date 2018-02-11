defmodule MMDB2Decoder.Data do
  @moduledoc """
  Module for decoding the mmdb2 format byte streams.
  """

  @type decoded :: atom | binary | boolean | list | map

  # standard data types
  @binary 2
  @bytes 4
  @double 3
  @extended 0
  @map 7
  @unsigned_16 5
  @unsigned_32 6
  @pointer 1

  # extended data types
  @extended_array 4
  @extended_bool 7
  @extended_cache 5
  @extended_end_marker 6
  @extended_float 8
  @extended_signed_32 1
  @extended_unsigned_64 2
  @extended_unsigned_128 3

  @doc """
  Decodes the datatype found at the given offset of the data.
  """
  @spec decode(binary, binary) :: {decoded, binary}
  def decode(<<@binary::size(3), len::size(5), part_rest::binary>>, _) do
    decode_binary(part_rest, len)
  end

  def decode(<<@bytes::size(3), len::size(5), part_rest::binary>>, _) do
    decode_binary(part_rest, len)
  end

  def decode(<<@double::size(3), 8::size(5), value::size(64)-float, part_rest::binary>>, _) do
    {Float.round(value, 8), part_rest}
  end

  def decode(<<@extended::size(3), len::size(5), @extended_array, part_rest::binary>>, data_full) do
    decode_array(part_rest, data_full, len)
  end

  def decode(<<@extended::size(3), value::size(5), @extended_bool, part_rest::binary>>, _) do
    {1 == value, part_rest}
  end

  def decode(<<@extended::size(3), _::size(5), @extended_cache, part_rest::binary>>, _) do
    {:cache, part_rest}
  end

  def decode(<<@extended::size(3), 0::size(5), @extended_end_marker, part_rest::binary>>, _) do
    {:end, part_rest}
  end

  def decode(
        <<
          @extended::size(3),
          4::size(5),
          @extended_float,
          value::size(32)-float,
          part_rest::binary
        >>,
        _
      ) do
    {Float.round(value, 4), part_rest}
  end

  def decode(<<@extended::size(3), len::size(5), @extended_signed_32, part_rest::binary>>, _) do
    decode_signed(part_rest, len * 8)
  end

  def decode(<<@extended::size(3), len::size(5), @extended_unsigned_64, part_rest::binary>>, _) do
    decode_unsigned(part_rest, len * 8)
  end

  def decode(<<@extended::size(3), len::size(5), @extended_unsigned_128, part_rest::binary>>, _) do
    decode_unsigned(part_rest, len * 8)
  end

  def decode(<<@map::size(3), len::size(5), part_rest::binary>>, data_full) do
    decode_map(part_rest, data_full, len)
  end

  def decode(<<@pointer::size(3), len::size(2), part_rest::bitstring>>, data_full) do
    decode_pointer(part_rest, data_full, len)
  end

  def decode(<<@unsigned_16::size(3), len::size(5), part_rest::binary>>, _) do
    decode_unsigned(part_rest, len * 8)
  end

  def decode(<<@unsigned_32::size(3), len::size(5), part_rest::binary>>, _) do
    decode_unsigned(part_rest, len * 8)
  end

  @doc """
  Decodes the node at the given offset.
  """
  @spec value(binary, non_neg_integer) :: decoded
  def value(data, offset) when byte_size(data) > offset do
    <<_::size(offset)-binary, rest::binary>> = data

    {value, _rest} = decode(rest, data)

    value
  end

  def value(_, _), do: nil

  # value decoding

  defp decode_array(data_part, data_full, len) do
    {data_part, size} = payload_len(data_part, len)

    decode_array_rec(data_part, data_full, size, [])
  end

  defp decode_array_rec(data_part, _, 0, acc) do
    {Enum.reverse(acc), data_part}
  end

  defp decode_array_rec(data_part, data_full, size, acc) do
    {value, rest} = decode(data_part, data_full)

    decode_array_rec(rest, data_full, size - 1, [value | acc])
  end

  defp decode_binary(data_part, len) do
    {data_part, len} = payload_len(data_part, len)

    <<value::size(len)-binary, rest::binary>> = data_part

    {value, rest}
  end

  defp decode_map(data_part, data_full, len) do
    {data_part, size} = payload_len(data_part, len)

    decode_map_rec(data_part, data_full, size, %{})
  end

  defp decode_map_rec(data_part, _, 0, acc) do
    {acc, data_part}
  end

  defp decode_map_rec(data_part, data_full, size, acc) do
    {key, part_rest} = decode(data_part, data_full)
    {value, dec_rest} = decode(part_rest, data_full)

    acc = Map.put(acc, String.to_atom(key), value)

    decode_map_rec(dec_rest, data_full, size - 1, acc)
  end

  defp decode_pointer(<<offset::size(11), rest::binary>>, data_full, 0) do
    {value(data_full, offset), rest}
  end

  defp decode_pointer(<<offset::size(19), rest::binary>>, data_full, 1) do
    {value(data_full, offset + 2048), rest}
  end

  defp decode_pointer(<<offset::size(27), rest::binary>>, data_full, 2) do
    {value(data_full, offset + 526_336), rest}
  end

  defp decode_pointer(<<_::size(3), offset::size(32), rest::binary>>, data_full, 3) do
    {value(data_full, offset), rest}
  end

  defp decode_signed(data_part, bitlen) do
    <<value::size(bitlen)-integer-signed, rest::binary>> = data_part

    {value, rest}
  end

  defp decode_unsigned(data_part, bitlen) do
    <<value::size(bitlen)-integer-unsigned, rest::binary>> = data_part

    {value, rest}
  end

  # payload detection

  defp payload_len(<<len::size(8), data::binary>>, 29) do
    {data, 29 + len}
  end

  defp payload_len(<<len::size(16), data::binary>>, 30) do
    {data, 285 + len}
  end

  defp payload_len(<<len::size(24), data::binary>>, 31) do
    {data, 65821 + len}
  end

  defp payload_len(data, len), do: {data, len}
end
