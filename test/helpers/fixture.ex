defmodule MMDB2Decoder.TestHelpers.Fixture do
  @moduledoc false

  alias MMDB2Decoder.TestHelpers.FixtureDownload
  alias MMDB2Decoder.TestHelpers.FixtureList

  @doc """
  Returns the binary contents of a fixture file.
  """
  @spec contents(atom) :: binary
  def contents(fixture) do
    fixture
    |> FixtureList.fixture_name()
    |> FixtureDownload.local()
    |> File.read!()
  end
end
