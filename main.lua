socket = require "socket"

state = "enter_name"
player_name = ""
adress, port = "localhost", 1349

function love.load()
	server = love.thread.newThread("server/main.lua")
	server:start()

	love.keyboard.setKeyRepeat(true)

	udp = socket.udp()
	udp:settimeout(0)
	udp:setpeername(adress, port)
	udp:send(string.format("%s %s %s", "plain", "send", "I like sausages!"))

	t = 0
	wait = true
end

--

function love.update(dt)
	if wait then
		t = t+dt

		if t > 5 then
			print("Client: Stop command sent to the server.")
			wait = false

			udp:send(string.format("%s %s $", "plain", "stop"))
		end
	end
end

function love.keypressed(key, is_repeat)
	if state == "enter_name" then
		if key == "backspace" then
			if #player_name > 0 then
				player_name = player_name:sub(1, #player_name-1)
			end
		elseif key == "return" and not is_repeat then
			connect()
		end
	end
end

function love.textinput(text)
	if state == "enter_name" then
		if #player_name <= 30 then
			player_name = player_name..text
		end
	end
end

function love.draw()
	if state == "enter_name" then
		love.graphics.print("Enter your name: "..player_name, 10, 10)
	end
end

--

function connect()
	state = "interactive"
end
