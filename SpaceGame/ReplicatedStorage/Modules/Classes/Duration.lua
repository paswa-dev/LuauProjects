local RS = game:GetService("RunService")

local IDuration = {
	RSConnection = nil,
	Instances = {},
	Queued = {},
}

local Duration = {}

--// Private Function

local function PerFrame(dt)
	local Queued = IDuration.Queued
	if #Queued > 0 then
		for i, entry in next, Queued do
			if entry.requestUnqueue then
				entry.requestUnqueue = false
				entry.isQueued = false
				entry.Unqueued()
				table.remove(Queued, i)
			else
				entry.duration = entry.__duration - dt
				entry.PerFrame()
			end
		end
	end
end

local function InitIDuration()
	if IDuration.RSConnection == nil then
		IDuration.RSConnection = RS.RenderStepped:Connect(PerFrame)
	end
end

--// Public Function

function IDuration.stopAll()
	for _, object in next, IDuration.Instances do
		object.duration = 0
	end
end

function IDuration.addTimer(name)
	local ObjectData = {}
	ObjectData.__duration = 0
	ObjectData.__maxDuration = 1
	ObjectData.name = name
	ObjectData.requestUnqueue = false
	ObjectData.isQueued = false
	ObjectData.PerFrame = function() end
	ObjectData.Queued = function() end
	ObjectData.Unqueued = function() end
	setmetatable(ObjectData, 
		{
			__index = Duration,
			__newindex = function(t, index, value)
				if index == "duration" then
					if value < 0 then value = 0 end
					if value == 0 then
						t.requestUnqueue = true
					else
						if t.isQueued == false then
							table.insert(IDuration.Queued, t)
							t.isQueued = true
							t.Queued()
						end
					end
					t.__duration = value
				end
			end
		}
	)
	IDuration.Instances[name] = ObjectData
	return ObjectData
end

function Duration:Increment(value)
	self.duration = self.__duration + value
	self.__maxDuration = self.__duration == 0 and 1 or self.__duration
end

function Duration:Update(value)
	self.duration = value
	self.__maxDuration = self.__duration == 0 and 1 or self.__duration
end

InitIDuration()
return IDuration
