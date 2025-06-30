local Replicated, Run = game:GetService("ReplicatedStorage"), game:GetService("RunService")
local IsServer = Run:IsServer()

local Remotes = Replicated:WaitForChild("Remotes")

local Net = {
	Registered = {}
}
local Stream = {
	Streams = {}
}
local MT = {__index = Stream}

local function Folder(name)
	local N_F = Instance.new("Folder")
	N_F.Name = name
	N_F.Parent = Remotes
	return N_F
end

local function Remote(name, path, udp)
	local N_R = udp and Instance.new("UnreliableRemoteEvent") or Instance.new("RemoteEvent")
	N_R.Name = name
	N_R.Parent = path
	return N_R
end

--// Other option is to store a entire tree of events. Probably not a good idea.

function Net.path(name)
	if Net.Registered[name] then
		return Net.Registered[name]
	else
		local Data = setmetatable({
			folder = IsServer and Folder(name) or Remotes:WaitForChild(name, 10)
		}, MT)
		Net.Registered[name] = Data
		return Data
	end
end
--// Re-use disconnected events.
--// Implement Rate Limiting

function Stream:stream(unique_id, udp: boolean?)
	if Stream[unique_id] then return Stream[unique_id] end
	local Remote : RemoteEvent = IsServer and Remote(unique_id, self.folder, udp) or self.folder:WaitForChild(unique_id, 10)
	if not Remote then
		warn(`>> Failed to resolve connection ({unique_id})`)
		return
	end
	local Data = {
		id = unique_id,
		folder = self.folder,
		events = {},
		disconnected_events = {},
		rate_limit = {
			_in = 1000,
			_out = 1000
		},
		rate_enabled = true,
		rate_schedule = 1 --// Seconds
	}
	local rate = {
		_in = 0,
		_out = 0
	}
	local schedule = {
		_in = os.clock(),
		_out = os.clock()
	}
	local RBXEvent : RBXScriptConnection
	
	local function CheckRate(networkPath : "_out" | "_in")
		if not Data.rate_enabled then return true end
		local T = os.clock() - schedule[networkPath]
		if T > Data.rate_schedule then
			schedule[networkPath] = schedule[networkPath] + T
			rate[networkPath] = 1
		else
			if rate[networkPath] >= Data.rate_limit[networkPath] then
				return false
			else
				rate[networkPath] = rate[networkPath] + 1
			end
		end
		return true
	end
	
	local CallAll = IsServer and function(plr, event, ...)
		if not Data.events[event] then return end
		if CheckRate("_in") then
			for _, Callback in next, Data.events[event] do
				Callback(plr, ...)
			end
		end
	end or function(event, ...)
		if not Data.events[event] then return end
		if CheckRate("_in") then
			for _, Callback in next, Data.events[event] do
				Callback(...)
			end
		end
	end
	
	if IsServer then
		function Data:Send(event, player: Player, ...)
			if CheckRate("_out") then
				Remote:FireClient(player, event, ...)
				return true
			end
		end
		
		function Data:SendToAll(event, ...)
			if CheckRate("_out") then
				Remote:FireAllClients(event, ...)
				return true
			end
		end
		
		function Data:SendToExcept(exceptions, event, ...)
			if CheckRate("_out") then
				for _, v in next, game.Players:GetPlayers() do
					if not table.find(exceptions, v) then
						Remote:FireClient(v, event, ...)
					end
				end
				return true
			end
		end
	else
		function Data:Send(event, ...)
			if CheckRate("_out") then
				Remote:FireServer(event, ...)
				return true
			end
		end
	end
	
	function Data:SetRateLimitInOut(_in: number, _out: number)
		if _in then
			Data.rate_limit["_in"] = _in
		end
		
		if _out then
			Data.rate_limit["_out"] = _out
		end
	end
	
	function Data:SetRateSchedule(seconds)
		Data.rate_schedule = seconds
	end
	
	function Data:SetRateLimit(_in_out: number)
		Data.rate_limit["_in"] = _in_out
		Data.rate_limit["_out"] = _in_out
	end
	
	function Data:Recieve(event, callback)
		if callback == nil then return end
		local EventCallbacks = Data.events[event]
		if not EventCallbacks then
			Data.events[event] = {}
			Data.disconnected_events[event] = {}
			EventCallbacks = Data.events[event]
		end
		local Disconnected = Data.disconnected_events[event]
		local Index
		if Disconnected[1] then
			Index = Disconnected[1]
			table.remove(Disconnected, 1)
		else
			Index = #EventCallbacks + 1
		end
		EventCallbacks[Index] = callback
		return {
			Disconnect = function()
				EventCallbacks[Index] = nil
				table.insert(Disconnected, Index)
			end,
		}
	end
	
	function Data:Establish()
		if not RBXEvent then
			RBXEvent = IsServer and Remote.OnServerEvent:Connect(CallAll) or Remote.OnClientEvent:Connect(CallAll)
		end
	end
	
	function Data:Cut()
		if RBXEvent then
			RBXEvent:Disconnect()
		end
	end
	Data:Establish()
	Stream.Streams[unique_id] = Data
	return Data
end

return Net