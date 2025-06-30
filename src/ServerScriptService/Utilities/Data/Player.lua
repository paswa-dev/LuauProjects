local ReplicationRemote : RemoteEvent = nil
local module = {
	data = {},
	replicated = {},
	onSetData = Instance.new("BindableEvent"),
	started = false
}

function module.init()
	if not module.started then
		module.started = true
		
		ReplicationRemote = Instance.new("RemoteEvent")
		ReplicationRemote.Name = "_PlayerReplicateData"
		ReplicationRemote.Parent = game:GetService("ReplicatedStorage").Remotes
		
		module.onSetData.Event:Connect(function(player, key, value)
			if module.replicated[player] then
				if module.replicated[player][key] then
					ReplicationRemote:FireClient(player, key, value)
				end
			end
		end)
	end
end

function module.SetPosition(player, pos)
	if player.Character then
		local HRP = player.Character:FindFirstChild("HumanoidRootPart")
		if HRP then HRP.Position = pos; return true end
	end
end

function module.GetPosition(player)
	if player.Character then
		local HRP = player.Character:FindFirstChild("HumanoidRootPart")
		if HRP then return HRP.Position end
	end
end

function module.BulkReplicateData(player, ...)
	for _, v in next, {...} do
		module.ReplicateData(player, v)
	end
end

function module.ReplicateData(player, key)
	if not module.replicated[player] then 
		module.replicated[player] = {}
	end
	table.insert(module.replicated[player], key)
end

function module.UnreplicateData(player, key)
	if module.replicated[player] then
		table.remove(module.replicated[player], table.find(module.replicated[player], key))
	end
end

function module.RemoveData(player)
	module.replicated[player] = nil
	module.data[player] = nil
end


function module.SetData(player, key, value)
	if not module.data[player] then
		module.data[player] = {}
	end
	module.onSetData:Fire(player, key, value)
	module.data[player][key] = value
end

function module.GetData(player, key)
	return module.data[player] and module.data[player][key] or nil
end

module.init()

return module
