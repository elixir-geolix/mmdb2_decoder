defmodule MMDB2Decoder.TestHelpers.FixtureDownload do
  @moduledoc false

  alias Geolix.TestData.MMDB2Fixture
  alias MMDB2Decoder.TestHelpers.FixtureList

  def local(filename), do: Path.join([path(), filename])
  def path, do: Path.join([__DIR__, "../fixtures"])
  def run, do: Enum.each(FixtureList.get(), &download/1)

  defp download({_name, filename}) do
    local = local(filename)

    if not File.regular?(local) do
      Mix.shell().info([:yellow, "Downloading fixture database: #{filename}"])
      MMDB2Fixture.download(filename, path())
    end
  end
end
