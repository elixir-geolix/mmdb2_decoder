defmodule MMDB2Decoder.ErrorNoMetadataTest do
  use ExUnit.Case, async: true

  @contents "broken-database-binary"
  @error {:error, :no_metadata}

  test "no metadata direct usage" do
    assert @error == MMDB2Decoder.parse_database(@contents)
  end

  test "no metadata piping usage" do
    result =
      @contents
      |> MMDB2Decoder.parse_database()
      |> MMDB2Decoder.pipe_lookup({127, 0, 0, 1})

    assert @error == result
  end
end
