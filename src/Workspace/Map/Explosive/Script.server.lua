local Parent = script.Parent
local Barrel = Parent.Parent.MetalBarrel
local paswa = Parent.Parent.paswa

Parent.ClickDetector.MouseClick:Connect(function()
	local Force = paswa.HumanoidRootPart.Position - Barrel.Position
	paswa.HumanoidRootPart.AssemblyLinearVelocity = Force * 50
	paswa.Head.Yell:Play()
	Barrel.Explosion:Play()
	
end)