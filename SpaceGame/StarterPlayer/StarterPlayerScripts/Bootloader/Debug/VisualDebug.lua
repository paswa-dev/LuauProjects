local Logs = game:GetService("LogService")
local Player = game:GetService("Players")
local Debris = game:GetService("Debris")
local PlayerGui = Player.LocalPlayer.PlayerGui
local debugBin = nil

local message_types = {
	[Enum.MessageType.MessageInfo] = Color3.new(0.12549, 0.54902, 1),
	[Enum.MessageType.MessageError] = Color3.new(0.819608, 0.521569, 0.184314),
	[Enum.MessageType.MessageOutput] = Color3.new(1, 1, 1),
	[Enum.MessageType.MessageWarning] = Color3.new(0.819608, 0.705882, 0.133333),
}

function newEntry(text, textColor)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "TextLabel"
	textLabel.Font = Enum.Font.Code
	textLabel.Text = text
	textLabel.TextColor3 = textColor
	textLabel.TextSize = 12
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.AutomaticSize = Enum.AutomaticSize.XY
	textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.BackgroundTransparency = 0.75
	textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.BorderSizePixel = 0

	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingLeft = UDim.new(0, 5)
	uIPadding.PaddingRight = UDim.new(0, 5)
	uIPadding.Parent = textLabel

	Debris:AddItem(textLabel, 10)
	textLabel.Parent = debugBin
end

function newDebug()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = string.format("%d-%s", math.random(0, 1000), "debug")
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 100000

	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Name = "UIListLayout"
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	uIListLayout.Parent = screenGui

	screenGui.Parent = PlayerGui
	debugBin = screenGui
	
	Logs.MessageOut:Connect(function(message, _type)
		if string.len(message) > 100 then return end
		newEntry(message, message_types[_type])
	end)
	print(">> Debugger: Console")
end

return {
	init = newDebug
}
