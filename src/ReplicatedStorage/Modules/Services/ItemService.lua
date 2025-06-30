local RP = game:GetService("ReplicatedStorage")
local Items = RP.Items

local isServer = game:GetService("RunService"):IsServer()

local Net = isServer and _G.fetch("Data/Net") or _G.get("Data/Net")

local item = {
	_registeredItems = {},
	_name_to_id = {},
	_output_registered = false,
}

--[[
This module registers any items needed from ReplicatedStorage/Items
This module will allow items to have functionality

revamp this a little more
]]

local function OutputToLog(name, id)
	if item._output_registered then
		warn(`>> {name} was registed as item {id}.`)
	end
end

function item.register(name, id, _stats, _behavior)
	if not _stats or not _behavior then warn("Failed to register, " .. name) return end
	local data = {
		id = id,
		name = name,
		behavior = _behavior,
		attributes = _stats,
	}
	data.behavior.net = Net.path("Items"):stream(id)
	data.behavior.net.rate_enabled = false
	data.behavior._parent = data
	if data.behavior["init"] then
		data.behavior.init()
	end
	item._name_to_id[data.name] = id
	item._registeredItems[id] = data
	OutputToLog(data.name, id)
	return data
end

function item.nameToId(name)
	return item._name_to_id[name]
end

function item.get(id_or_name)
	return item._registeredItems[type(id_or_name) == "string" and item._name_to_id[id_or_name] or id_or_name]
end

function item.getBehavior(id_or_name)
	local found = item.get(id_or_name)
	return found and found["behavior"] or nil
end

function item.registerModule(module)
	local data = require(module)
	local name = data["name"] or module.Name
	local behavior = isServer and require(module.Server) or require(module.Client)
	return item.register(data.name, data.id, data, behavior)
end

return item