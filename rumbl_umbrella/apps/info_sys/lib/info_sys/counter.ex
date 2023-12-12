defmodule InfoSys.Counter do
  # use GenServer, restart: :permanent
  use GenServer

  # client side

  def increment(pid), do: GenServer.cast(pid, :increment)
  def decrement(pid), do: GenServer.cast(pid, :decrement)
  def value(pid), do: GenServer.call(pid, :value)

  def start_link(initial_value) do
    GenServer.start_link(__MODULE__, initial_value)
  end

  # server side

  # def child_spec(arg) do
  #   %{
  #     id: __MODULE__,
  #     start: {__MODULE__, :start_link, [arg]},
  #     restart: :temporary,
  #     shutdown: 5_000,
  #     type: :worker
  #   }
  # end

  @impl true
  def init(initial_value) do
    Process.send_after(self(), :tick, 1_000)
    {:ok, initial_value}
  end

  @impl true
  def handle_cast(:increment, value), do: {:noreply, value + 1}

  @impl true
  def handle_cast(:decrement, value), do: {:noreply, value - 1}

  @impl true
  def handle_call(:value, _from, value), do: {:reply, value, value}

  @impl true
  def handle_info(:tick, 0), do: raise("Boom!")

  @impl true
  def handle_info(:tick, value) do
    IO.puts("tick #{value}")
    Process.send_after(self(), :tick, 1_000)
    {:noreply, value - 1}
  end
end
