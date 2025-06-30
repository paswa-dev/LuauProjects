local RS = game:GetService("RunService")

local stress = 0
local stress_decay = 0.5
local min, max = 0, 1

local maxShake = Vector3.new(math.rad(10), math.rad(10), math.rad(25))

local camera = workspace.CurrentCamera
local random = Random.new()

local perlin = math.noise

local elapsed = 0

local module = {}

local Seed = random:NextInteger(0, 10000000000)

local function update(dt)
	local accountStress = stress_decay * dt
	stress = math.clamp(stress - accountStress, min, max)
	local Preserved = camera.CFrame
	local CS = math.pow(stress, 2)
	local ShakeX = maxShake.X * CS * perlin(Seed, elapsed * 10)
	local ShakeY = maxShake.Y * CS * perlin(Seed+100, elapsed * 10)
	local ShakeZ = maxShake.Z * CS * perlin(Seed+200, elapsed * 10)
	camera.CFrame *= CFrame.Angles(ShakeX, ShakeY, ShakeZ)
	if stress == 0 and elapsed ~= 0 then
		elapsed = 0
	end
	
	if stress ~= 0 then
		elapsed += dt
	end
end

function module.add(value)
	Seed = random:NextInteger(0, 10000000000)
	stress = math.clamp(stress + (value or 0.1), min, max)
end

RS.RenderStepped:Connect(update)

return module