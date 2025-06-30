local GuiBin = game.Players.LocalPlayer.PlayerGui
local Placeholders = GuiBin:WaitForChild("Placeholders")
local UIComps = GuiBin.UIComponents

local module = {}

local function inverseLerp(a, b, c)
	return (c - a) / (b - a)
end

local function cloneStat(text, color)
	local clone = Placeholders.Stat:Clone()
	clone.Fill.BackgroundColor3 = color
	clone.Title.Text = text
	clone.Parent = nil
	return clone
end

function module.new(name, color, hidden: boolean?)
	local data = {}
	data.name = name
	data.object = cloneStat(name, color)
	
	function data.set(value, min: number?, max : number?)
		if min and max then
			value = inverseLerp(min, max, value)
		end
		data.object.Fill.Size = UDim2.fromScale(value, 1)
	end
	
	function data.show()
		data.object.Parent = UIComps.Stats
	end
	
	function data.hide()
		data.object.Parent = nil
	end
	
	if not hidden then
		data.show()
	end
	
	return data
end

return module
