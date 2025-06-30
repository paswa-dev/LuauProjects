local fetch = _G.fetch
local ItemService = fetch "Services/ItemService"

local item = {
	Players = {},
	removing = Instance.new("BindableEvent"),
	adding = Instance.new("BindableEvent"),
	changed = Instance.new("BindableEvent")
}
local player = {}
local mt = {__index = player}

function item.new(player)
	local data = {
		player = player,
		items = {},
		_subdata = {}
	}
	setmetatable(data, mt)
	item.Players[player] = data
	return data
end

function item.get(player)
	return item.Players[player]
end

function item.remove(player)
	item.Players[player] = nil
	return item.Players[player] == nil
end

function player:Add(id_or_name, quantity)
	local id = type(id_or_name) == "string" and ItemService.nameToId(id_or_name) or id_or_name
	if id and type(id) == "number" then
		if not self.items[id] then
			self.items[id] = ItemService.get(id)
			self._subdata[id] = quantity or 1
			item.adding:Fire(self.player, id, quantity)
		else
			self._subdata[id] = self._subdata[id] + (quantity or 1)
			item.changed:Fire(self.player, self:Get(id))
		end
		return true
	else
		warn(`>> Unable to add {quantity} to {id_or_name}`)
	end
end

function player:Remove(id_or_name, quantity)
	local id = type(id_or_name) == "string" and ItemService.nameToId(id_or_name) or id_or_name
	if id and type(id) == "number" then
		if self.items[id] then
			self._subdata[id] = self._subdata[id] - (quantity or 1)
			if self._subdata[id] < 1 then
				self._subdata[id] = nil
				self.items[id] = nil
				item.removing:Fire(self.player, id)
			else
				item.changed:Fire(self.player, self:Get(id))
			end
			return true
		else
			warn(`{id_or_name} does not exist.`)
		end
	else
		warn(`>> Unable to add {quantity} to {id_or_name}`)
	end
end

function player:Get(id_or_name)
	local id = type(id_or_name) == "string" and ItemService.nameToId(id_or_name) or id_or_name
	if id then
		return self.items[id], self._subdata[id]
	else
		warn(`>> Failed to get {id_or_name}`)
	end
end

return item