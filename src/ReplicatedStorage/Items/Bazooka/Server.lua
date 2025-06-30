--[[
//name:Item
//id:ServerSide
]]
local get = _G.get
local remote = _G.remote
local fetch = _G.fetch

local server = {
	players = {}
} :: {[any] : any}


function server.init()
	server.net:Establish()
	server.net:Recieve("fire", server.fire)
end

function server.add(player)
	server.players[player] = 1
end

function server.remove(player)
	server.players[player] = nil
end

function server.fire(player, lookvector)
	if server.players[player] then
		print("Firing...")
	end
end

return server