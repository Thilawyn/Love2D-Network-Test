socket = require "socket"

function love.load()
	local adress, port = "localhost", 349

	server = love.thread.newThread("server/main.lua")
	server:start()

	udp = socket.udp()
	udp:settimeout(0)
	udp:setpeername(adress, port)
	udp:send(string.format("%s %s %s", "plain", "send", "I like sausages!"))

	t = 0
	wait = true
end

function love.update(dt)
	if wait then
		t = t+dt

		if t > 5 then
			print("Client: Stop command sent to the server.")
			wait = false

			udp:send(string.format("%s %s", "plain", "stop"))
		end
	end
end

function love.draw()

end
