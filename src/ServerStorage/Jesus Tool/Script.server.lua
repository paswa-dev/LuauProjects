local RS = game:GetService("RunService")
local Tool = script.Parent
local requestFly = Tool.requestFly

local Zero = Vector3.zero
local FlightSpeed = 10

local function CreateAttachment(HumanoidRootPart)
	local newAttachment = Instance.new("Attachment")
	newAttachment.Name = "Force"
	newAttachment.Parent = HumanoidRootPart
	return newAttachment
end

local function CreateVectorForce(character)
	local newForce = Instance.new("VectorForce")
	newForce.Attachment0 = CreateAttachment(character.HumanoidRootPart)
	newForce.ApplyAtCenterOfMass = true --// To balance the object
	newForce.Parent = newForce.Attachment0
	return newForce
end

local function makeJesusNoise()
	game.SoundService["Angelic Ah Sting"]:Play()
	game.SoundService.hamburger:Play()
	task.wait(1.5)
	game.SoundService.hamburger:Play()
	task.wait(1.5)
	game.SoundService.hamburger:Play()
end

local function onRequest(plr, method, lookVector) --// Really is no way to compact a vector and send over server : (
	if method == "Start" then
		makeJesusNoise()
		local CharacterModel = plr.Character
		local Mass = CharacterModel.HumanoidRootPart:GetMass()
		local Weight = Mass * workspace.Gravity
		local Force = CreateVectorForce(CharacterModel)
		Force.Force = Vector3.new(0, Weight, 0)
		--RS:BindToRenderStep("FlightPhysics", 100, function()
		--	CharacterModel.HumanoidRootPart.AssemblyLinearVelocity = Zero:Lerp(getlookvector:InvokeClient(plr) * FlightSpeed, 0.1)
		--end)
	elseif method == "Stop" then
		RS:UnbindFromRenderStep("FlightPhysics")
		if plr.Character then
			if plr.Character.HumanoidRootPart:FindFirstChild("Force") then
				plr.Character.HumanoidRootPart.Force:Destroy()
			end
		end
	end
end

requestFly.OnServerEvent:Connect(onRequest)