defmodule MMDB2Decoder.Metadata do
  @moduledoc """
  Metadata struct.
  """

  @type t :: %__MODULE__{
          binary_format_major_version: non_neg_integer,
          binary_format_minor_version: non_neg_integer,
          build_epoch: non_neg_integer,
          database_type: String.t(),
          description: map,
          ip_version: non_neg_integer,
          languages: list,
          node_byte_size: non_neg_integer,
          node_count: non_neg_integer,
          record_size: non_neg_integer,
          tree_size: non_neg_integer
        }

  defstruct binary_format_major_version: 0,
            binary_format_minor_version: 0,
            build_epoch: 0,
            database_type: "",
            description: %{},
            ip_version: 0,
            languages: [],
            node_byte_size: 0,
            node_count: 0,
            record_size: 0,
            tree_size: 0
end
