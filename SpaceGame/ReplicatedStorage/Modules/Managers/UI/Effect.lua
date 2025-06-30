local get = _G.get
local IDuration = get "Classes/Duration"

local RS = game:GetService("RunService")

local GuiBin = game.Players.LocalPlayer.PlayerGui
local Placeholders = GuiBin:WaitForChild("Placeholders")
local UIComps = GuiBin.UIComponents

local module = {}

local function cloneEffect(color)
	local clone = Placeholders.Effect:Clone()
	clone.Fill.BackgroundColor3 = color
	clone.Parent = nil
	return clone
end

function module.new(name, color)
	local data = {}
	data.name = name
	data.color = color
	data.object = cloneEffect(color)
	data.timer = IDuration.addTimer(name .. "Effect")
	
	data.timer.PerFrame = function()
		local Duration, MaxDuration = data.timer.__duration, data.timer.__maxDuration
		data.object.Title.Text = string.format("%s (%d)", data.name, math.round(Duration))
		data.object.Fill.Size = UDim2.fromScale(Duration/MaxDuration, 1)
	end
	
	data.timer.Unqueued = function()
		data.object.Parent = nil
	end
	
	data.timer.Queued = function()
		data.object.Parent = UIComps.Effects
	end
	
	return setmetatable(data, {__index = module})
end

function module:AddTime(value)
	self.timer:Increment(value)
end

function module:SetDuration(value)
	self.timer:Update(value)
end

return module
