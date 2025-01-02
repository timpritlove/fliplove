defmodule Ping do
  @moduledoc false

  import Bitwise
  require Logger

  def ping(address) do
    Task.async(fn ->
      {:ok, socket} = :gen_icmp.open()
      :ok = :gen_icmp.echoreq(socket, address, <<1, 2, 3, 4>>)
      Logger.info("sent ping")

      receive do
        {:icmp, pid, addr, {:echorep, data}} ->
          IO.inspect(pid, label: "pid")
          IO.inspect(addr, label: "addr")
          IO.inspect(data, label: "data")

          :ok

        other ->
          IO.inspect(other, label: "other")
      end
    end)
    |> Task.await()
  end

  #   def ping(host) do
  #     {:ok, socket} = :gen_udp.open(0, [:binary, :inet, :raw])
  #     message = build_icmp_message()
  #     :gen_udp.send(socket, message, {host, 0})
  #     receive_response(socket)
  #     :gen_udp.close(socket)
  #   end
  # end

  def rfc1071_checksum(data) when is_binary(data) do
    sum_up(data, 0) |> chop_and_carry_word() |> bnot()
  end

  defp chop_and_carry_word(number) when number < 0x10000, do: number
  defp chop_and_carry_word(number), do: chop_and_carry_word((number &&& 0xFFFF) + (number >>> 16))

  defp sum_up(<<>>, sum), do: sum
  defp sum_up(<<word::16, rest::binary>>, sum), do: sum_up(rest, word + sum)
  defp sum_up(<<byte::8, rest::binary>>, sum), do: sum_up(rest, (byte <<< 8) + sum)
end
