local module = {}
local exclusions = {
	Root = 0,
	RootJoint = 0,
}

local function DisableMotors(motors)
	for limb, motorArray in next, motors do
		for _, motor in next, motorArray do
			motor.Enabled = false
			motor.Parent = nil
		end
	end
end

local function EnableMotors(model, motors)
	for limb, motorArray in next, motors do
		for _, motor in next, motorArray do
			motor.Enabled = true
			motor.Parent = model[limb]
		end
	end
end

local function CreateBallSocketJoints(model, motor_mapping)
	for limb, motorArray in next, motor_mapping do
		for _, motor : Motor6D in next, motorArray do
			if not exclusions[motor.Name] then
				local BallSocketJoint = script[motor.Name]:Clone()
				local Attachment0 = Instance.new("Attachment")
				local Attachment1 = Instance.new("Attachment")
				Attachment0.Name = "RagdollConstraint"
				Attachment1.Name = "RagdollConstraint"
				BallSocketJoint.Name = "RagdollConstraint"
				Attachment0.CFrame = motor.C0
				Attachment1.CFrame = motor.C1
				BallSocketJoint.Attachment0 = Attachment0
				BallSocketJoint.Attachment1 = Attachment1
				Attachment1.Parent = motor.Part1
				Attachment0.Parent = motor.Part0
				BallSocketJoint.Parent = model[limb]
				BallSocketJoint.Enabled = true
			end
		end
	end
end

function module.setup(character: Model)
	local Data = {
		_motors = {},
		_ballsocketjoints = {},
		_character = character,
	}
	for _, object in character:GetDescendants() do
		if object:IsA("Motor6D") then
			if exclusions[object.Name] == nil then
				if not Data._motors[object.Parent.Name] then
					Data._motors[object.Parent.Name] = {}
				end
				table.insert(Data._motors[object.Parent.Name], object)
			end
		end
	end
	return setmetatable(Data, {__index = module})
end

function module:Ragdoll()
	local Humanoid, HRP = self._character.Humanoid, self._character.HumanoidRootPart
	Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	HRP.CanCollide = false
	HRP.Massless = true
	DisableMotors(self._motors)
	CreateBallSocketJoints(self._character, self._motors)
end

function module:Undo()
	local Humanoid, HRP = self._character.Humanoid, self._character.HumanoidRootPart
	EnableMotors(self._character, self._motors)
	for _, object in self._character:GetDescendants() do
		if object.Name == "RagdollConstraint" or object:IsA("BallSocketConstraint") then
			object:Destroy()
		end
	end
	
	
	
	Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	
	HRP.CanCollide = true
	HRP.Massless = false
end

function module:Destroy()
	for limb, motorArray in next, self._motors do
		for _, motor in next, motorArray do
			motor:Destroy()
		end
	end
end

return module
