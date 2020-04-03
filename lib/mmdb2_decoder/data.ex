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
  @extended_boolean 7
  @extended_cache_container 5
  @extended_end_marker 6
  @extended_float 8
  @extended_signed_32 1
  @extended_unsigned_64 2
  @extended_unsigned_128 3

  @doc """
  Decodes the node at the given offset.
  """
  @spec value(binary, non_neg_integer, MMDB2Decoder.decode_options()) ::
          MMDB2Decoder.lookup_value()
  def value(data, offset, options) when byte_size(data) > offset and offset >= 0 do
    <<_::size(offset)-binary, rest::binary>> = data

    {value, _rest} = decode(rest, data, options)

    value
  end

  def value(_, _, _), do: nil

  defp decode(<<@binary::size(3), 0::size(5), part_rest::binary>>, _, _) do
    {"", part_rest}
  end

  defp decode(<<@binary::size(3), 29::size(5), len::size(8), part_rest::binary>>, _, _) do
    decode_binary(part_rest, 29 + len)
  end

  defp decode(<<@binary::size(3), 30::size(5), len::size(16), part_rest::binary>>, _, _) do
    decode_binary(part_rest, 285 + len)
  end

  defp decode(<<@binary::size(3), 31::size(5), len::size(24), part_rest::binary>>, _, _) do
    decode_binary(part_rest, 65_821 + len)
  end

  defp decode(<<@binary::size(3), len::size(5), part_rest::binary>>, _, _) do
    decode_binary(part_rest, len)
  end

  defp decode(<<@bytes::size(3), 0::size(5), part_rest::binary>>, _, _) do
    {"", part_rest}
  end

  defp decode(<<@bytes::size(3), 29::size(5), len::size(8), part_rest::binary>>, _, _) do
    decode_binary(part_rest, 29 + len)
  end

  defp decode(<<@bytes::size(3), 30::size(5), len::size(16), part_rest::binary>>, _, _) do
    decode_binary(part_rest, 285 + len)
  end

  defp decode(<<@bytes::size(3), 31::size(5), len::size(24), part_rest::binary>>, _, _) do
    decode_binary(part_rest, 65_821 + len)
  end

  defp decode(<<@bytes::size(3), len::size(5), part_rest::binary>>, _, _) do
    decode_binary(part_rest, len)
  end

  defp decode(
         <<@double::size(3), 8::size(5), value::size(64)-float, part_rest::binary>>,
         _,
         options
       ) do
    {maybe_round_double(value, options), part_rest}
  end

  defp decode(
         <<@double::size(3), 8::size(5), value::size(64), part_rest::binary>>,
         _,
         options
       ) do
    {maybe_round_double(:erlang.float(value), options), part_rest}
  end

  defp decode(
         <<@extended::size(3), 29::size(5), len::size(8), @extended_array, part_rest::binary>>,
         data_full,
         options
       ) do
    decode_array(part_rest, data_full, 28 + len, [], options)
  end

  defp decode(
         <<@extended::size(3), 30::size(5), len::size(16), @extended_array, part_rest::binary>>,
         data_full,
         options
       ) do
    decode_array(part_rest, data_full, 285 + len, [], options)
  end

  defp decode(
         <<@extended::size(3), 31::size(5), len::size(24), @extended_array, part_rest::binary>>,
         data_full,
         options
       ) do
    decode_array(part_rest, data_full, 65_821 + len, [], options)
  end

  defp decode(
         <<@extended::size(3), len::size(5), @extended_array, part_rest::binary>>,
         data_full,
         options
       ) do
    decode_array(part_rest, data_full, len, [], options)
  end

  defp decode(<<@extended::size(3), 0::size(5), @extended_boolean, part_rest::binary>>, _, _) do
    {false, part_rest}
  end

  defp decode(<<@extended::size(3), 1::size(5), @extended_boolean, part_rest::binary>>, _, _) do
    {true, part_rest}
  end

  defp decode(
         <<@extended::size(3), _::size(5), @extended_cache_container, part_rest::binary>>,
         _,
         _
       ) do
    {:cache_container, part_rest}
  end

  defp decode(<<@extended::size(3), 0::size(5), @extended_end_marker, part_rest::binary>>, _, _) do
    {:end_marker, part_rest}
  end

  defp decode(
         <<
           @extended::size(3),
           4::size(5),
           @extended_float,
           value::size(32)-float,
           part_rest::binary
         >>,
         _,
         options
       ) do
    {maybe_round_float(value, options), part_rest}
  end

  defp decode(
         <<
           @extended::size(3),
           4::size(5),
           @extended_float,
           value::size(32),
           part_rest::binary
         >>,
         _,
         options
       ) do
    {maybe_round_float(:erlang.float(value), options), part_rest}
  end

  defp decode(<<@extended::size(3), len::size(5), @extended_signed_32, part_rest::binary>>, _, _) do
    decode_signed(part_rest, len * 8)
  end

  defp decode(
         <<@extended::size(3), len::size(5), @extended_unsigned_64, part_rest::binary>>,
         _,
         _
       ) do
    decode_unsigned(part_rest, len * 8)
  end

  defp decode(
         <<@extended::size(3), len::size(5), @extended_unsigned_128, part_rest::binary>>,
         _,
         _
       ) do
    decode_unsigned(part_rest, len * 8)
  end

  defp decode(<<@map::size(3), 29::size(5), len::size(8), part_rest::binary>>, data_full, options) do
    decode_map(part_rest, data_full, 28 + len, [], options)
  end

  defp decode(
         <<@map::size(3), 30::size(5), len::size(16), part_rest::binary>>,
         data_full,
         options
       ) do
    decode_map(part_rest, data_full, 285 + len, [], options)
  end

  defp decode(
         <<@map::size(3), 31::size(5), len::size(24), part_rest::binary>>,
         data_full,
         options
       ) do
    decode_map(part_rest, data_full, 65_821 + len, [], options)
  end

  defp decode(<<@map::size(3), len::size(5), part_rest::binary>>, data_full, options) do
    decode_map(part_rest, data_full, len, [], options)
  end

  defp decode(
         <<@pointer::size(3), 0::size(2), offset::size(11), part_rest::bitstring>>,
         data_full,
         options
       ) do
    {value(data_full, offset, options), part_rest}
  end

  defp decode(
         <<@pointer::size(3), 1::size(2), offset::size(19), part_rest::bitstring>>,
         data_full,
         options
       ) do
    {value(data_full, 2048 + offset, options), part_rest}
  end

  defp decode(
         <<@pointer::size(3), 2::size(2), offset::size(27), part_rest::bitstring>>,
         data_full,
         options
       ) do
    {value(data_full, 526_336 + offset, options), part_rest}
  end

  defp decode(
         <<@pointer::size(3), 3::size(2), _::size(3), offset::size(32), part_rest::bitstring>>,
         data_full,
         options
       ) do
    {value(data_full, offset, options), part_rest}
  end

  defp decode(<<@unsigned_16::size(3), len::size(5), part_rest::binary>>, _, _) do
    decode_unsigned(part_rest, len * 8)
  end

  defp decode(<<@unsigned_32::size(3), len::size(5), part_rest::binary>>, _, _) do
    decode_unsigned(part_rest, len * 8)
  end

  defp decode_array(data_part, _, 0, acc, _) do
    {Enum.reverse(acc), data_part}
  end

  defp decode_array(data_part, data_full, size, acc, options) do
    {value, rest} = decode(data_part, data_full, options)

    decode_array(rest, data_full, size - 1, [value | acc], options)
  end

  defp decode_binary(data_part, len) do
    <<value::size(len)-binary, rest::binary>> = data_part

    {value, rest}
  end

  defp decode_map(data_part, _, 0, acc, _) do
    {Map.new(acc), data_part}
  end

  defp decode_map(data_part, data_full, size, acc, options) do
    {key, part_rest} = decode(data_part, data_full, options)
    {value, dec_rest} = decode(part_rest, data_full, options)

    key = maybe_convert_map_key(key, options)

    decode_map(dec_rest, data_full, size - 1, [{key, value} | acc], options)
  end

  defp decode_signed(data_part, bitlen) do
    <<value::size(bitlen)-integer-signed, rest::binary>> = data_part

    {value, rest}
  end

  defp decode_unsigned(data_part, bitlen) do
    <<value::size(bitlen)-integer-unsigned, rest::binary>> = data_part

    {value, rest}
  end

  defp maybe_convert_map_key(value, %{map_keys: :atoms}), do: String.to_atom(value)
  defp maybe_convert_map_key(value, %{map_keys: :atoms!}), do: String.to_existing_atom(value)
  defp maybe_convert_map_key(value, %{map_keys: :strings}), do: value
  defp maybe_convert_map_key(value, _), do: value

  defp maybe_round_double(value, %{double_precision: nil}), do: value

  defp maybe_round_double(value, %{double_precision: precision}),
    do: Float.round(value, precision)

  defp maybe_round_double(value, _), do: value

  defp maybe_round_float(value, %{float_precision: nil}), do: value
  defp maybe_round_float(value, %{float_precision: precision}), do: Float.round(value, precision)
  defp maybe_round_float(value, _), do: value
end
