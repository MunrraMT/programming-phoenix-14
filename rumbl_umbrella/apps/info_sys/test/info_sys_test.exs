defmodule InfoSysTest do
  use ExUnit.Case, async: true
  doctest InfoSys
  alias InfoSys.Result

  defmodule TestBackend do
    def name(), do: "Wolfram"

    def compute("none", _opts), do: []
    def compute("boom", _opts), do: raise("boom!")
    def compute("timeout", _opts), do: Process.sleep(:infinity)

    def compute("result", _opts) do
      [%Result{backend: __MODULE__, text: "result"}]
    end
  end

  test "compute/2 with backend results" do
    assert [%Result{backend: TestBackend, text: "result"}] =
             InfoSys.compute("result", backends: [TestBackend])
  end

  test "compute/2 with no backend results" do
    assert [] = InfoSys.compute("none", backends: [TestBackend])
  end

  test "compute/2 with timeout returns no results" do
    assert [] = InfoSys.compute("timeout", backends: [TestBackend], timeout: 10)
  end

  @tag :capture_log
  test "compute/2 discards backend errors" do
    assert [] = InfoSys.compute("boom", backends: [TestBackend])
  end
end
