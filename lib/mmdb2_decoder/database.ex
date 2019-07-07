defmodule MMDB2Decoder.Database do
  @moduledoc false

  alias MMDB2Decoder.Data
  alias MMDB2Decoder.Metadata

  @metadata_marker <<0xAB, 0xCD, 0xEF>> <> "MaxMind.com"
  @metadata_max_size 128 * 1024

  @doc """
  Splits database contents into data and metadata.
  """
  @spec split_contents(binary) :: [binary]
  def split_contents(contents) when byte_size(contents) > @metadata_max_size do
    :binary.split(
      contents,
      @metadata_marker,
      scope: {byte_size(contents), -@metadata_max_size}
    )
  end

  def split_contents(contents), do: :binary.split(contents, @metadata_marker)

  @doc """
  Splits the data part according to a metadata definition.
  """
  @spec split_data(binary, binary) ::
          {:ok, Metadata.t(), binary, binary} | {:error, :invalid_node_count}
  def split_data(meta, data) do
    meta = Data.value(meta, 0, MMDB2Decoder.default_options())

    meta = %Metadata{
      binary_format_major_version: meta["binary_format_major_version"],
      binary_format_minor_version: meta["binary_format_minor_version"],
      build_epoch: meta["build_epoch"],
      database_type: meta["database_type"],
      description: meta["description"],
      ip_version: meta["ip_version"],
      languages: meta["languages"],
      node_count: meta["node_count"],
      record_size: meta["record_size"]
    }

    %{node_count: node_count, record_size: record_size} = meta

    node_byte_size = div(record_size, 4)
    tree_size = node_count * node_byte_size

    if tree_size < byte_size(data) do
      meta = %{meta | node_byte_size: node_byte_size}
      meta = %{meta | tree_size: tree_size}

      tree = binary_part(data, 0, tree_size)
      data_size = byte_size(data) - byte_size(tree) - 16
      data = binary_part(data, tree_size + 16, data_size)

      {:ok, meta, tree, data}
    else
      {:error, :invalid_node_count}
    end
  end
end
