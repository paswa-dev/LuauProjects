local Parent = script.Parent
local Insane = Parent.Insanity
local Speed = Parent.Speed
local Strength = Parent.Strength

local function OnTouch(otherPart, name, duration)
	local Player: Player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
	game.ReplicatedStorage.Remotes.UI.EffectUpdate:FireClient(Player, "Add", name, duration)
end


Insane.Touched:Connect(function(other)
	OnTouch(other, Insane.Name, 5)
end)

Speed.Touched:Connect(function(other)
	OnTouch(other, Speed.Name, 2)
end)

Strength.Touched:Connect(function(other)
	OnTouch(other, Strength.Name, 3)
end)

Parent.HurtPerson.Touched:Connect(function(other)
	local Humanoid = other.Parent:FindFirstChild("Humanoid") :: Humanoid?
	if Humanoid then Humanoid.Health = Humanoid.Health - 10 end
end)