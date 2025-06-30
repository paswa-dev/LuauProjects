local ReplicationRemote : RemoteEvent = nil
local module = {
	data = {},
	onSetData = Instance.new("BindableEvent"),
	started = false
}

function module.init()
	if not module.started then
		module.started = true

		ReplicationRemote = game:GetService("ReplicatedStorage").Remotes:WaitForChild("_PlayerReplicateData")

		ReplicationRemote.OnClientEvent:Connect(function(key, value)
			module.SetData(key, value)
		end)
	end
end

function module.GetPosition(player)
	if player.Character then
		local HRP = player.Character:FindFirstChild("HumanoidRootPart")
		if HRP then return HRP.Position end
	end
end

function module.SetData(key, value)
	module.onSetData:Fire(key, value)
	module.data[key] = value
end

function module.GetData(key)
	return module.data[key]
end

module.init()

return module
