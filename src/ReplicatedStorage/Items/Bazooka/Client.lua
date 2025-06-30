local get = _G.get

local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local Camera = workspace.CurrentCamera
local Player = game.Players.LocalPlayer

local LoadedData

local Maid = get "Shared/Maid"
local Spring = get "Shared/Spring"
local Observer = get "Shared/Observer"
local Signal = get "Shared/FastSignal"
local Graphs = get "Math/Graphs"
local Character = get "Services/Character"

local Pattern = Graphs.figuregraph

local started = false
local module = {
	maid = Maid.new(),
	springs = {
		Recoil = Spring.new(Vector3.zero, 10, 0.9),
		Angle = Spring.new(Vector3.zero, 20, 1),
		Bobble = Spring.new(Vector2.zero, 1, 1),
		MasterAngle = Spring.new(math.pi/2, 4, 1),
		Movement = Spring.new(0, 3, 0.5)
	},
	events = {
		reload = Signal.new(),
		fire = Signal.new(),
		aim = Signal.new(),
		equipping = Signal.new(),
		unequipping = Signal.new()
	},
	observers = {
		--// I think this was for events, like firing and stuff. Make a sperate module for that.
	},
	model = nil,
	elapsed = 0,
}



local function start()
	if not started then
		started = true
		LoadedData = require(script.Parent.Data)
		module.model = LoadedData.model:Clone()
	end
end

function module:updateMath(dt)
	local springs = self.springs
	local MoveDirection = Character.MoveDirection()
	springs.Bobble.Target = Pattern(self.elapsed * 16, 1) * (MoveDirection.Magnitude)
	springs.Movement.Target = math.clamp(Character.Velocity().Y, -0.3, 0.3)
end

function module:updateArms(dt)
	local Springs = self.springs
	local model = self.model
	local RCFrame = workspace.CurrentCamera.CFrame

	local Angle = Springs.Angle.Value
	local MAngle = Springs.MasterAngle.Value
	local Bobble = Springs.Bobble.Value
	-- ToWorldSpace maybe? Unless its not faster, idk.
	RCFrame *= CFrame.new(0, Springs.Movement.Value, 0)
	RCFrame *= CFrame.Angles(MAngle, 0, 0)
	RCFrame *= CFrame.Angles(Angle.X, Angle.Y, Angle.Z)
	RCFrame *= CFrame.new(Bobble.X, Bobble.Y, 0)
	RCFrame *= CFrame.new(Springs.Recoil.Value)
	model:PivotTo(RCFrame)
end

function module:onSpawn()
	self.springs.MasterAngle.Target = 0
end

function module:updateSprings(dt)
	for _, v in next, self.springs do
		v:TimeSkip(dt)
	end
end

function module:fire()
	self.net:Send("fire")
	self.springs.MasterAngle:Impulse(math.pi/5)
end

function module:hook()
	self.maid:GiveTask(RS.RenderStepped:Connect(function(dt)
		self:updateMath(dt)
		self:updateSprings(dt)
		self:updateArms(dt)
		self.elapsed += dt
	end))
	self.maid:GiveTask(
		UIS.InputBegan:Connect(function(input, gpe)
			if not gpe and input.UserInputType == Enum.UserInputType.MouseButton1 then
				self:fire()
			end
		end)
	)
	self.net:Establish()
	--self:bind() // Undo this when you finally make it. Basically binds everything
end

function module:unhook()
	self.net:Cut()
	self.maid:DoCleaning()
	self.elapsed = 0
end

function module:spawn(yieldUntil)
	if not Player.Character then if yieldUntil then Player.CharacterAdded:Wait() else return "bad" end end
	self.model.Parent = workspace
	self:hook()
	self:onSpawn()
end

function module:despawn()
	self.model.Parent = nil
	self:unhook()
end

start()

return module
