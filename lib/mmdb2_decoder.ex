defmodule MMDB2Decoder do
  @moduledoc """
  MMDB2 file format decoder.

  ## Usage

  To prepare lookups in a given database you need to parse it
  and hold the result available for later usage:

      iex(1)> database = File.read!("/path/to/database.mmdb")
      iex(2)> {:ok, meta, tree, data} = MMDB2Decoder.parse_database(database)

  Using the returned database contents you can start looking up
  individual entries:

      iex(3)> {:ok, ip} = :inet.parse(String.to_charlist("127.0.0.1"))
      iex(4)> MMDB2Decoder.lookup(ip, meta, tree, data)
      {:ok, %{...}}

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

  @type lookup_result :: {:ok, term} | {:error, term}
  @type parse_result :: {:ok, Metadata.t(), binary, binary} | {:error, term}

  @doc """
  Looks up the data associated with an IP tuple.

  This is probably the main function you will use. The `ip` address is expected
  to be a 4- or 8-element tuple describing an IPv4 or IPv6 address. To obtain
  this tuple from a string you can use `:inet.ip_address/1`.

  ## Usage

      iex> MMDB2Decoder.lookup({127, 0, 0, 1}, meta, tree, data)
      {
        :ok,
        %{
          continent: %{...},
          country: %{...},
          registered_country: %{...}
        }
      }

  The values for `meta`, `tree` and `data` can be obtained by
  parsing the file contents of a database using `parse_database/1`.
  """
  @spec lookup(:inet.ip_address(), Metadata.t(), binary, binary) :: lookup_result
  def lookup(ip, meta, tree, data) do
    case LookupTree.locate(ip, meta, tree) do
      {:error, _} = error -> error
      {:ok, pointer} -> Database.lookup_pointer(pointer, data, meta)
    end
  end

  @doc """
  Parses a database binary and splits it into metadata, lookup tree and data.

  It is expected that you pass the real contents of the file, not the name
  of the database or the path to it.

  ## Usage

      iex> MMDB2Decoder.parse_database(File.read!("/path/to/database.mmdb"))
      {
        :ok,
        %MMDB2Decoder.Metadata{...},
        <<...>>,
        <<...>>
      }

  If parsing the database fails you will receive an appropriate error tuple:

      iex> MMDB2Decoder.parse_database("invalid-database-contents")
      {:error, :no_metadata}
  """
  @spec parse_database(binary) :: parse_result
  def parse_database(contents) do
    case Database.split_contents(contents) do
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
      {:ok, %{...}}
  """
  @spec pipe_lookup(parse_result, :inet.ip_address()) :: lookup_result
  def pipe_lookup({:error, _} = error, _), do: error
  def pipe_lookup({:ok, meta, tree, data}, ip), do: lookup(ip, meta, tree, data)
end
