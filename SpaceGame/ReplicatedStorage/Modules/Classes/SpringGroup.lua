local RunService = game:GetService("RunService")
local get = RunService:IsServer() and _G.fetch or _G.get
local hasRan = false
local Spring

local Group = {}

local function Initialize()
	if not hasRan then
		Spring = get "Shared/Spring"
		hasRan = true
	end
end

function Group.new()
	return setmetatable({
		springs = {},
	}, {__index = Group})
end

function Group:New(name, v, s, d)
	self.springs[name] = Spring.new(v, s, d)
	return self.springs[name]
end

function Group:Remove(name)
	self.springs[name] = nil
end

function Group:TimeSkip(dt: number)
	for _, s in next, self.springs do
		s:TimeSkip(dt)
	end
end

function Group:Value(name: string)
	return self.springs[name] and self.springs[name].Value or nil
end

function Group:Get(name: string)
	return self.springs[name]
end

Initialize()
return Group