local garbage = {}

local function cleanup(t, deep)
	for i, v in next, t do
		local foundType = typeof(v)
		if foundType == "function" then
			v()
			v = nil
		elseif foundType == "Instance" then
			v:Destroy()
		elseif foundType == "RBXScriptConnection" then
			v:Disconnect()
		elseif foundType == "table" and deep then
			cleanup(v, deep)
		else
			v = nil
		end
	end
end

function garbage.new()
	local VirtualBin = {}
	local Methods = {}
	
	function Methods:trash(deep)
		task.spawn(cleanup, VirtualBin, deep)
	end
	
	return setmetatable(Methods, {__index = VirtualBin, __newindex = VirtualBin})
end

return garbage
