local socket = require "socket"

local state = "enter_name"
local player_name = ""
local command = ""
local adress, port = "localhost", 1349
local udp = socket.udp()

function love.load()
	server = love.thread.newThread("server/main.lua")
	server:start()

	love.keyboard.setKeyRepeat(true)
end

local updaterate = 0.1
local t = 0
local chat = {}

--

function love.update(dt)
	t = t+dt

	if t >= updaterate then
		repeat
			local data, msg = udp:receive()

			if data then
				local cmd, params = data:match("^(%S*) (.*)")

				if state == "waiting_for_entity" then
					if cmd == "entity" then
						entity = params
						print("Client: You have been logged in by the server with entity ID "..entity..".")
						state = "interactive"
					end
				elseif state == "interactive" then
					if cmd == "chat" then
						local name, message = params:match("^(%S*) (.*)")
						table.insert(chat, name..": "..message)
					end
				end
			end
		until not data

		t = 0
	end
end

function love.keypressed(key, is_repeat)
	if state == "enter_name" then
		if key == "backspace" then
			if #player_name > 0 then
				player_name = player_name:sub(1, #player_name-1)
			end
		elseif key == "return" and not is_repeat then
			request_login()
		end
	elseif state == "interactive" then
		if key == "backspace" then
			if #command > 0 then
				command = command:sub(1, #command-1)
			end
		elseif key == "return" and not is_repeat then
			send_command()
		end
	end
end

function love.textinput(text)
	if state == "enter_name" then
		if #player_name <= 30 then
			player_name = player_name..text
		end
	elseif state == "interactive" then
		if #command <= 256 then
			command = command..text
		end
	end
end

function love.draw()
	if state == "enter_name" then
		love.graphics.print("Enter your name: "..player_name, 10, 10)
	elseif state == "interactive" then
		love.graphics.print("> "..command, 10, 10)

		for k, v in ipairs(chat) do
			love.graphics.print(v, 10, 20+k*10)
		end
	end
end

--

function request_login()
	udp:settimeout(0)
	udp:setpeername(adress, port)
	udp:send(string.format("%s %s %s", "none", "login", player_name))

	state = "waiting_for_entity"
end

function send_command()
	udp:send(string.format("%s %s %s", entity, "chat", command))
	command = ""
end
