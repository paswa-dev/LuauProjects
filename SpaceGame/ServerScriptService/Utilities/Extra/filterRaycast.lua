return function(
	origin,
	direction,
	ignoreList,
	ignoreFunction,
	ignoreWater
)
	local RP = RaycastParams.new()
	RP.FilterDescendantsInstances = ignoreList
	RP.FilterType = Enum.RaycastFilterType.Exclude
	RP.IgnoreWater = ignoreWater or false
	
	local Result = nil
	
	while true do
		local _result = workspace:Raycast(origin, direction, RP)
		if _result then
			if not ignoreFunction(_result.Instance) then
				Result = _result
				break
			else
				table.insert(ignoreList, _result.Instance)
				RP.FilterDescendantsInstances = ignoreList
			end
		else
			break
		end
	end
	
	return Result
end