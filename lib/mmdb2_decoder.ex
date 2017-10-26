defmodule MMDB2Decoder do
  @moduledoc """
  MMDB2 file format decoder.
  """

  alias MMDB2Decoder.Data
  alias MMDB2Decoder.Database
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
    case :binary.split(contents, @metadata_marker) do
      [_] -> {:error, :no_metadata}
      [data, meta] -> Database.split_data(meta, data)
    end
  end

  @doc """
  Utility method to pipe `parse_database/1` directly to `lookup/4`.
  """
  @spec pipe_lookup({Metadata.t(), binary, binary}, tuple) :: map | nil
  def pipe_lookup({meta, tree, data}, ip), do: lookup(ip, meta, tree, data)

  defp lookup_pointer(0, _, _), do: nil

  defp lookup_pointer(ptr, data, node_count) do
    offset = ptr - node_count - 16

    case Data.value(data, offset) do
      result when is_map(result) -> result
      _ -> nil
    end
  end
end
