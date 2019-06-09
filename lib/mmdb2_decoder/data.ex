defmodule MMDB2Decoder.Data do
  @moduledoc false

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
  @spec decode(binary, binary) :: {MMDB2Decoder.decoded_value(), binary}
  def decode(<<@binary::size(3), 29::size(5), len::size(8), part_rest::binary>>, _) do
    decode_binary(part_rest, 29 + len)
  end

  def decode(<<@binary::size(3), 30::size(5), len::size(16), part_rest::binary>>, _) do
    decode_binary(part_rest, 285 + len)
  end

  def decode(<<@binary::size(3), 31::size(5), len::size(24), part_rest::binary>>, _) do
    decode_binary(part_rest, 65_821 + len)
  end

  def decode(<<@binary::size(3), len::size(5), part_rest::binary>>, _) do
    decode_binary(part_rest, len)
  end

  def decode(<<@bytes::size(3), 29::size(5), len::size(8), part_rest::binary>>, _) do
    decode_binary(part_rest, 29 + len)
  end

  def decode(<<@bytes::size(3), 30::size(5), len::size(16), part_rest::binary>>, _) do
    decode_binary(part_rest, 285 + len)
  end

  def decode(<<@bytes::size(3), 31::size(5), len::size(24), part_rest::binary>>, _) do
    decode_binary(part_rest, 65_821 + len)
  end

  def decode(<<@bytes::size(3), len::size(5), part_rest::binary>>, _) do
    decode_binary(part_rest, len)
  end

  def decode(<<@double::size(3), 8::size(5), value::size(64)-float, part_rest::binary>>, _) do
    {Float.round(value, 8), part_rest}
  end

  def decode(
        <<@extended::size(3), 29::size(5), len::size(8), @extended_array, part_rest::binary>>,
        data_full
      ) do
    decode_array(part_rest, data_full, 28 + len, [])
  end

  def decode(
        <<@extended::size(3), 30::size(5), len::size(16), @extended_array, part_rest::binary>>,
        data_full
      ) do
    decode_array(part_rest, data_full, 285 + len, [])
  end

  def decode(
        <<@extended::size(3), 31::size(5), len::size(24), @extended_array, part_rest::binary>>,
        data_full
      ) do
    decode_array(part_rest, data_full, 65_821 + len, [])
  end

  def decode(<<@extended::size(3), len::size(5), @extended_array, part_rest::binary>>, data_full) do
    decode_array(part_rest, data_full, len, [])
  end

  def decode(<<@extended::size(3), 0::size(5), @extended_bool, part_rest::binary>>, _) do
    {false, part_rest}
  end

  def decode(<<@extended::size(3), 1::size(5), @extended_bool, part_rest::binary>>, _) do
    {true, part_rest}
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

  def decode(<<@map::size(3), 29::size(5), len::size(8), part_rest::binary>>, data_full) do
    decode_map(part_rest, data_full, 28 + len, [])
  end

  def decode(<<@map::size(3), 30::size(5), len::size(16), part_rest::binary>>, data_full) do
    decode_map(part_rest, data_full, 285 + len, [])
  end

  def decode(<<@map::size(3), 31::size(5), len::size(24), part_rest::binary>>, data_full) do
    decode_map(part_rest, data_full, 65_821 + len, [])
  end

  def decode(<<@map::size(3), len::size(5), part_rest::binary>>, data_full) do
    decode_map(part_rest, data_full, len, [])
  end

  def decode(<<@pointer::size(3), 0::size(2), offset::size(11), part_rest::bitstring>>, data_full) do
    {value(data_full, offset), part_rest}
  end

  def decode(<<@pointer::size(3), 1::size(2), offset::size(19), part_rest::bitstring>>, data_full) do
    {value(data_full, 2048 + offset), part_rest}
  end

  def decode(<<@pointer::size(3), 2::size(2), offset::size(27), part_rest::bitstring>>, data_full) do
    {value(data_full, 526_336 + offset), part_rest}
  end

  def decode(<<@pointer::size(3), 3::size(2), offset::size(32), part_rest::bitstring>>, data_full) do
    {value(data_full, offset), part_rest}
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
  @spec value(binary, non_neg_integer) :: MMDB2Decoder.lookup_value()
  def value(data, offset) when byte_size(data) > offset do
    <<_::size(offset)-binary, rest::binary>> = data

    {value, _rest} = decode(rest, data)

    value
  end

  def value(_, _), do: nil

  # value decoding

  defp decode_array(data_part, _, 0, acc) do
    {Enum.reverse(acc), data_part}
  end

  defp decode_array(data_part, data_full, size, acc) do
    {value, rest} = decode(data_part, data_full)

    decode_array(rest, data_full, size - 1, [value | acc])
  end

  defp decode_binary(data_part, len) do
    <<value::size(len)-binary, rest::binary>> = data_part

    {value, rest}
  end

  defp decode_map(data_part, _, 0, acc) do
    {Map.new(acc), data_part}
  end

  defp decode_map(data_part, data_full, size, acc) do
    {key, part_rest} = decode(data_part, data_full)
    {value, dec_rest} = decode(part_rest, data_full)

    decode_map(dec_rest, data_full, size - 1, [{String.to_atom(key), value} | acc])
  end

  defp decode_signed(data_part, bitlen) do
    <<value::size(bitlen)-integer-signed, rest::binary>> = data_part

    {value, rest}
  end

  defp decode_unsigned(data_part, bitlen) do
    <<value::size(bitlen)-integer-unsigned, rest::binary>> = data_part

    {value, rest}
  end
end
