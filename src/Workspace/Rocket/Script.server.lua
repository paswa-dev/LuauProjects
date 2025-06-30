local Rocket = script.Parent
local Curve = Rocket.Curve
local ModelRocket = Rocket.Model

function easeInExpo(x: number): number
	return x == 0 and 0 or math.pow(2, 10 * x - 10);
end

function easeOutQuart(x: number): number
	return 1 - math.pow(1 - x, 4)
end

local function Lerp(t, a, b)
	return a + ((b-a) * t)
end

local function BezierCurve(t, a, b, c)
	local A_l = Lerp(t, a, b)
	local B_l = Lerp(t, b, c)
	return Lerp(t, A_l, B_l)
end

local function timeOnCurve(t)
	return BezierCurve(t, Curve.One.Position, Curve.Two.Position, Curve.Three.Position)
end
local played = false

game:GetService("SoundService")["BOOM-Ambient Synth Boom 02"]:Play()

for i = 100, 0, -0.1 do
	task.wait()
	local percentile = (easeInExpo(i/100))
	ModelRocket.PrimaryPart.CFrame = CFrame.new(timeOnCurve(percentile), timeOnCurve(percentile + 0.000001)) * CFrame.Angles(-math.pi/2, 0, 0)
	if percentile <= 0.04 and not played then
		ModelRocket.Rocket.RocketSlowing:Play()
		played = true
	end
end
ModelRocket.Rocket.RocketSlowing:Stop()
ModelRocket.Rocket.RocketStop:Play()
task.wait(0.5)
ModelRocket.Rocket.Payload:Destroy()
Rocket.Payload.AssemblyLinearVelocity = Vector3.new(10,10, 0)
task.wait(2)
ModelRocket.Rocket["RocketSlowing"]:Play()
for i = 0, 100, 0.1 do
	task.wait()
	local percentile = (easeInExpo(i/100))
	ModelRocket.PrimaryPart.CFrame = CFrame.new(timeOnCurve(percentile), timeOnCurve(percentile + 0.000001)) * CFrame.Angles(-math.pi/2, 0, 0)
end