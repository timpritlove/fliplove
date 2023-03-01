# defmodule Ping do
#   def ping(host) do
#     {:ok, socket} = :gen_udp.open(0, [:binary, :inet, :raw])
#     message = build_icmp_message()
#     :gen_udp.send(socket, message, {host, 0})
#     receive_response(socket)
#     :gen_udp.close(socket)
#   end
# end
