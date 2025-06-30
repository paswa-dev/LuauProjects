local RUN_SERVICE = game:GetService("RunService")
local GET = _G.get
local SPRING = GET "Classes/SpringGroup"
local MAID = GET "Shared/Maid"
local BASE = {}
local METHODS = {}

function BASE.extend()
	return setmetatable({
		_CONNECTION = nil,
		_UPDATES = {},
		_SGROUP = SPRING.new(),
		MAID = MAID.new(),
	}, {__index = METHODS})
end

function METHODS:_updateSprings(dt: number)
	self._SGROUP:TimeSkip(dt)
end

function METHODS:_bind(loop: RBXScriptSignal)
	self._CONNECTION = loop:Connect(function(...)
		for _, UPDATE in next, self._UPDATES do
			self:_updateSprings(...)
			UPDATE(...)
		end
	end)
end

function METHODS:_unBind()
	self._CONNECTION:Disconnect()
	self._CONNECTION = nil
end

function METHODS:removeUpdate(name)
	self._UPDATES[name] = nil
end

function METHODS:removeSpring(name)
	self._SGROUP:Remove(name)
end

function METHODS:insertUpdate(name, callback)
	self._UPDATES[name] = callback
end

function METHODS:insertSpring(...)
	self._SGROUP:New(...)
end

function METHODS:spawn(loop: RBXScriptSignal?)
	if self._CONNECTION == nil then
		self:_bind(loop or RUN_SERVICE.RenderStepped)
		if self:onSpawn() == false then
			self:unspawn()
		end
	end
end

function METHODS:unspawn()
	if self._CONNECTION then
		self:onUnspawn()
		self:_unBind()
		self.MAID:DoCleaning()
	end
end

function METHODS:onSpawn() end

function METHODS:onUnspawn() end

return table.freeze(METHODS)