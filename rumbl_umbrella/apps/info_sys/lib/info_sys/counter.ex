defmodule InfoSys.Counter do
  use GenServer

  # client side

  def increment(pid), do: GenServer.cast(pid, :increment)
  def decrement(pid), do: GenServer.cast(pid, :decrement)
  def value(pid), do: GenServer.call(pid, :value)

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value, name: __MODULE__)
  end

  # server side

  def init(initial_value) do
    Process.send_after(self(), :tick, 1000)
    {:ok, initial_value}
  end

  def handle_cast(:increment, value), do: {:noreply, value + 1}
  def handle_cast(:decrement, value), do: {:noreply, value - 1}
  def handle_call(:value, _from, value), do: {:reply, value, value}

  def handle_info(:tick, 0), do: raise("Boom!")

  def handle_info(:tick, value) do
    IO.puts("tick #{value}")
    Process.send_after(self(), :tick, 1000)
    {:noreply, value - 1}
  end
end
