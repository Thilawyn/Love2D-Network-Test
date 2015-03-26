local socket = require "socket"

local udp = socket.udp()
udp:settimeout(0)
udp:setsockname("*", 1349)

local running = true
local players = {}

print("==> Server is running...")
while running do
	local data, ip, port = udp:receivefrom()

	if data then
		local entity, cmd, params = data:match("^(%S*) (%S*) (.*)")

		if entity == "none" then
			if cmd == "login" then
				math.randomseed(os.time())
				local new_entity = tostring(math.random(99999))
				players[new_entity] = {
					name = params,
					ip = ip,
					port = port
				}

				print("==> Player "..params.."@"..ip..":"..port.." has logged in with entity ID "..new_entity..".")
				udp:sendto(string.format("%s %s", "entity", new_entity), ip, port)
			end
		elseif type(players[entity]) == nil then
			udp:sendto(string.format("%s %s", "error", "auth_error"), ip, port)
		else
			if cmd == "chat" then
				print("==> "..players[entity].name..": "..params)

				for k, v in pairs(players) do
					udp:sendto(string.format("%s %s %s", "chat", players[entity].name, params), v.ip, v.port)
				end
			end
		end
	end

	socket.sleep(0.01)
end

udp:close()
print("==> Server closed.")