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

  ## Lookup Options

  The behaviour of the decoder can be adjusted by passing an option map as the
  last argument to the lookup functions:

      iex> MMDB2Decoder.lookup(ip, meta, tree, data, %{map_keys: :atoms!})

  The following options are available:

  - `:map_keys` defines the type of the keys in a decoded map:
      - `:strings` is the default value
      - `:atoms` uses `String.to_atom/1`
      - `:atoms!` uses `String.to_existing_atom/1`
  - `:double_precision` defines the precision of decoded Double values
      - `nil` is the default for "unlimited" precision
      - any value from `t:Float.precision_range/0` to round the precision to
  - `:float_precision` defines the precision of decoded Float values
      - `nil` is the default for "unlimited" precision
      - any value from `t:Float.precision_range/0` to round the precision to
  """

  alias MMDB2Decoder.Data
  alias MMDB2Decoder.Database
  alias MMDB2Decoder.LookupTree
  alias MMDB2Decoder.Metadata

  @type decode_options :: %{
          optional(:double_precision) => nil | Float.precision_range(),
          optional(:float_precision) => nil | Float.precision_range(),
          optional(:map_keys) => nil | :atoms | :atoms! | :strings
        }

  @type decoded_value :: :cache_container | :end_marker | binary | boolean | list | map | number
  @type lookup_value :: decoded_value | nil

  @type lookup_result :: {:ok, lookup_value} | {:error, term}
  @type parse_result :: {:ok, Metadata.t(), binary, binary} | {:error, term}
  @type tree_result :: {:ok, non_neg_integer} | {:error, term}

  @default_decode_options %{
    double_precision: nil,
    float_precision: nil,
    map_keys: :strings
  }

  @doc """
  Fetches the pointer of an IP in the data if available.

  The pointer will be calculated to be relative to the start of the binary data.

  ## Usage

      iex> MMDB2Decoder.find_pointer({127, 0, 0, 1}, meta, tree)
      123456
  """
  @spec find_pointer(:inet.ip_address(), Metadata.t(), binary) :: tree_result
  def find_pointer(ip, meta, tree) do
    case LookupTree.locate(ip, meta, tree) do
      {:error, _} = error -> error
      {:ok, pointer} -> {:ok, pointer - meta.node_count - 16}
    end
  end

  @doc """
  Calls `find_pointer/3` and raises if an error occurs.
  """
  @spec find_pointer!(:inet.ip_address(), Metadata.t(), binary) :: non_neg_integer | no_return
  def find_pointer!(ip, meta, tree) do
    case find_pointer(ip, meta, tree) do
      {:ok, pointer} -> pointer
      {:error, error} -> raise Kernel.to_string(error)
    end
  end

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
          "continent" => %{...},
          "country" => %{...},
          "registered_country" => %{...}
        }
      }

  The values for `meta`, `tree` and `data` can be obtained by
  parsing the file contents of a database using `parse_database/1`.
  """
  @spec lookup(:inet.ip_address(), Metadata.t(), binary, binary, decode_options) :: lookup_result
  def lookup(ip, meta, tree, data, options \\ @default_decode_options) do
    case find_pointer(ip, meta, tree) do
      {:error, _} = error -> error
      {:ok, pointer} -> lookup_pointer(pointer, data, options)
    end
  end

  @doc """
  Calls `lookup/4` and raises if an error occurs.
  """
  @spec lookup!(:inet.ip_address(), Metadata.t(), binary, binary, decode_options) ::
          lookup_value | no_return
  def lookup!(ip, meta, tree, data, options \\ @default_decode_options) do
    case lookup(ip, meta, tree, data, options) do
      {:ok, result} -> result
      {:error, error} -> raise Kernel.to_string(error)
    end
  end

  @doc """
  Fetches the data at a given pointer position.

  The pointer is expected to be relative to the start of the binary data.

  ## Usage

      iex> MMDB2Decoder.lookup_pointer(123456, data)
      {
        :ok,
        %{
          "continent" => %{...},
          "country" => %{...},
          "registered_country" => %{...}
        }
      }
  """
  @spec lookup_pointer(non_neg_integer, binary, decode_options) :: {:ok, lookup_value}
  def lookup_pointer(pointer, data, options \\ @default_decode_options) do
    {:ok, Data.value(data, pointer, options)}
  end

  @doc """
  Calls `lookup_pointer/3` and unrolls the return tuple.
  """
  @spec lookup_pointer!(non_neg_integer, binary, decode_options) :: lookup_value
  def lookup_pointer!(pointer, data, options \\ @default_decode_options) do
    {:ok, value} = lookup_pointer(pointer, data, options)

    value
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
  @spec pipe_lookup(parse_result, :inet.ip_address(), decode_options) :: lookup_result
  def pipe_lookup(parse_result, ip, options \\ @default_decode_options)

  def pipe_lookup({:error, _} = error, _, _), do: error

  def pipe_lookup({:ok, meta, tree, data}, ip, options),
    do: lookup(ip, meta, tree, data, options)

  @doc """
  Calls `pipe_lookup/2` and raises if an error from `parse_database/1` is given
  or occurs during `lookup/4`.
  """

  @spec pipe_lookup!(parse_result, :inet.ip_address(), decode_options) ::
          lookup_value | no_return
  def pipe_lookup!(parse_result, ip, options \\ @default_decode_options)

  def pipe_lookup!({:error, error}, _, _), do: raise(Kernel.to_string(error))

  def pipe_lookup!({:ok, meta, tree, data}, ip, options),
    do: lookup!(ip, meta, tree, data, options)
end
