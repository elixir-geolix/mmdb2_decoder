defmodule MMDB2Decoder do
  @moduledoc """
  MMDB2 file format decoder.

  ## Usage

  To prepare lookups in a given database you need to parse it
  and hold the result available for later usage:

      iex(1)> database = File.read!("/path/to/database.mmdb")
      iex(2)> {meta, tree, data} = MMDB2Decoder.parse_database(database)

  Using the returned database contents you can start looking up
  individual entries:

      iex(3)> {:ok, ip} = :inet.parse(String.to_charlist("127.0.0.1"))
      iex(4)> MMDB2Decoder.lookup(ip, meta, tree, data)
      %{...}

  For more details on the lookup methods (and a function suitable for
  direct piping) please see the individual function documentations.

  ### Floating Point Precision

  Please be aware that all values of the type `float` are rounded to 4
  decimal digits and `double` values to 8 decimal digits.

  This might be changed in the future if there are datasets known to
  return values with a higher precision.
  """

  alias MMDB2Decoder.Database
  alias MMDB2Decoder.LookupTree
  alias MMDB2Decoder.Metadata

  @metadata_marker <<0xAB, 0xCD, 0xEF>> <> "MaxMind.com"

  @doc """
  Looks up the data associated with an IP tuple.

  This is probably the main function you will use. The `ip` address is expected
  to be a 4- or 8-element tuple describing an IPv4 or IPv6 address. To obtain
  this tuple from a string you can use `:inet.ip_address/1`.

  ## Usage

      iex> MMDB2Decoder.lookup({127, 0, 0, 1}, meta, tree, data)
      %{
        continent: %{...},
        country: %{...},
        registered_country: %{...}
      }

  The values for `meta`, `tree` and `data` can be obtained by
  parsing the file contents of a database using `parse_database/1`.
  """
  @spec lookup(:inet.ip_address(), Metadata.t(), binary, binary) :: map | nil
  def lookup(ip, meta, tree, data) do
    ip
    |> LookupTree.locate(meta, tree)
    |> Database.lookup_pointer(data, meta)
  end

  @doc """
  Parses a database binary and splits it into metadata, lookup tree and data.

  It is expected that you pass the real contents of the file, not the name
  of the database or the path to it.

  ## Usage

      iex> MMDB2Decoder.parse_database(File.read!("/path/to/database.mmdb"))
      {
        %MMDB2Decoder.Metadata{...},
        <<...>>,
        <<...>>
      }

  If parsing the database fails you will receive an appropriate error tuple:

      iex> MMDB2Decoder.parse_database("invalid-database-contents")
      {:error, :no_metadata}
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

  ## Usage

  Depending on how you handle the parsed database contents you may
  want to pass the results directly to the lookup.

      iex> "/path/to/database.mmdb"
      ...> |> File.read!()
      ...> |> MMDB2Decoder.parse_database()
      ...> |> MMDB2Decoder.pipe_lookup({127, 0, 0, 1})
      %{...}
  """
  @spec pipe_lookup({Metadata.t(), binary, binary}, :inet.ip_address()) :: map | nil
  def pipe_lookup({meta, tree, data}, ip), do: lookup(ip, meta, tree, data)
end
