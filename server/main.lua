local socket = require "socket"

udp = socket.udp()
udp:settimeout(0)
udp:setsockname("*", 1349)

local running = true

print("==> Server is running...")
while running do
	local data, ip, port = udp:receivefrom()

	if data then
		print("Data received.")

		local data_type, cmd, params = data:match("^(%S*) (%S*) (.*)")

		if data_type == "plain" then
			if cmd == "send" then
				print("Client "..ip.." sent: "..params)
			elseif cmd == "stop" then
				running = false
				print("==> Server is stopping...")
			end
		end
	end

	socket.sleep(0.01)
end

udp:close()
print("==> Server stopped!")
