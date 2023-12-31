defmodule InfoSys.Test.HTTPClient do
  @wolfram_xml File.read!(__DIR__ <> "/../fixtures/wolfram.xml")

  def request(url) do
    cond do
      String.contains?(to_string(url), "1+%2B+1") ->
        {:ok, {[], [], @wolfram_xml}}

      true ->
        {:ok, {[], [], "<queryresult></queryresult>"}}
    end
  end
end
