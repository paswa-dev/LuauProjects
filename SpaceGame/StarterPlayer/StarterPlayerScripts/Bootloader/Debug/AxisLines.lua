local get = _G.get

local Length = 10000000000
local AxisStorage = workspace:WaitForChild("Debug")
local AxisAdornee = workspace:WaitForChild("SpawnLocation")

local function createAxis(direction)
	local LineHandle = Instance.new("LineHandleAdornment")
	LineHandle.AdornCullingMode = Enum.AdornCullingMode.Never
	LineHandle.Color3 = Color3.new(direction.X, direction.Y, direction.Z)
	LineHandle.CFrame = CFrame.new(Vector3.zero, direction)
	LineHandle.AlwaysOnTop = true
	LineHandle.Length = Length
	LineHandle.Thickness = 2
	LineHandle.Adornee = AxisAdornee

	local LineHandleNegative = LineHandle:Clone()
	LineHandle.CFrame = CFrame.new(Vector3.zero, -direction)
	LineHandle.Parent = AxisStorage
	LineHandleNegative.Parent = AxisStorage
	return {LineHandle, LineHandleNegative}
end

local function main()
	local AxisController = {
		X = createAxis(Vector3.FromAxis(Enum.Axis.X)),
		Y = createAxis(Vector3.FromAxis(Enum.Axis.Y)),
		Z = createAxis(Vector3.FromAxis(Enum.Axis.Z)),	
	}
	print(">> Debugger: Visual Axis")
end

return {
	init = main
}