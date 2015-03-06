socket = require "socket"

udp = socket.udp()
udp:settimeout(0)
udp:setsockname("*", 349)

local running = true

print("==> Server is running...")
while running do
	local data, ip, port = udp:receivefrom()

	if data then
		print("Data received.")

		local data_type, cmd, params = data:match("^(%S*) (%S*) (.*)")
		print(data_type)
		print(cmd)

		if #params > 0 then
			print("Params has "..#params.." values.")
		end

		if data_type == "plain" then
			if cmd == "send" then
				if #params < 1 then
					print("The client sent a wrong command!")
				else
--~ 					print("The client sent: "..params[1])
				end
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
