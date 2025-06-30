local Tool = script.Parent
local requestFly = Tool.requestFly

Tool.Equipped:Connect(function()
	requestFly:FireServer("Start")
end)

Tool.Unequipped:Connect(function()
	requestFly:FireServer("Stop")
end)
