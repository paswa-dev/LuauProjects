local player = game.Players.LocalPlayer

local module = {}

function module.MoveDirection()
	if not player.Character then return end
	return player.Character.Humanoid.MoveDirection
end

function module.Position()
	if not player.Character then return end
	return player.Character.PrimaryPart.Position
end

function module.Humanoid(yield)
	if not player.Character then return end
	return yield and player.Character:WaitForChild("Humanoid") or player.Character.Humanoid
end

function module.Exist()
	return player.Character ~= nil
end

function module.Velocity()
	return player.Character.PrimaryPart.AssemblyLinearVelocity
end

return module
