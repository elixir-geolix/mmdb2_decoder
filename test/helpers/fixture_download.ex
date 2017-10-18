defmodule MMDB2Decoder.TestHelpers.FixtureDownload do
  @moduledoc false

  alias MMDB2Decoder.TestHelpers.FixtureList

  @doc """
  Returns the full local pathname of a fixture filename.
  """
  def local(filename) do
    [__DIR__, "../fixtures/", filename]
    |> Path.join()
    |> Path.expand()
  end

  @doc """
  Downloads all fixture files.
  """
  def run(), do: Enum.each(FixtureList.get(), &download/1)

  defp download({_name, filename, remote}) do
    local = local(filename)

    if not File.regular?(local) do
      Mix.shell().info([:yellow, "Downloading fixture database: #{filename}"])

      download_fixture(remote, local)
    end
  end

  defp download_fixture(remote, local) do
    {:ok, _} = Application.ensure_all_started(:hackney)
    {:ok, _, _, client} = :hackney.get(remote)
    {:ok, content} = :hackney.body(client)

    File.write!(local, content)
  end
end
