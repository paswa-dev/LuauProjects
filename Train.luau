--!strict
-- Paswa 7/3/2025
-- Property of 8NEC studios
-- https://www.roblox.com/communities/32749380/8th-Noobic-Engineering-Corps#!/about

-- Services
local RS = game:GetService("RunService")
-- Modules
local CATROM = require("./CatRom")
local CATROM_TYPES = require("./CatRom/Types")
local SIGNAL = require("./Signal")
-- Variables (DO NOT TOUCH UNLESS IT SAYS YOU CAN)
local TManager = {}
TManager._instance = nil :: any
TManager._spline = nil :: any
TManager._spline_totalLength = 0 :: number
TManager._elapsedTime = 0 :: number


TManager._heartbeatConnection = nil :: RBXScriptConnection?

TManager._carts = {} :: {Model}
-- Manual States
TManager._stopping = false :: boolean
TManager._running = false :: boolean
-- Automatic States
TManager._stopped = true :: boolean
TManager._signalStopped = SIGNAL.new()
TManager._signalMoving = SIGNAL.new()
TManager._signalStopUpdate = SIGNAL.new()

-- Stopping
TManager._stops = {} :: {BasePart}
TManager._currentStop = 1 :: number

-- Velocity/PID stuff
TManager._targetVelocity = 0 :: number
TManager._velocity = 0 :: number
TManager._maxVelocity = 100 :: number

-- You can touch these!
TManager._stoppingRange = 5 :: number -- I do suggest not touching this 
TManager._velocitySpeedup = .5 :: number -- Must be divisible by 2
TManager._velocityDecay = .5 :: number -- Must be divisible by 2
TManager._fixedTotalTime = 1 * 60 :: number -- Minutes (from seconds) [DISABLED]
TManager._fixedStudsVelocity = 20 :: number -- Random number (stud/s, pick one when you need)
TManager._overrideSpeedToTotalTime = true :: boolean -- If you want to use the fixed total time set to true

TManager._timeBetweenStops = 20 :: number -- Seconds
TManager._timeBetweenNextTrain = 15 * 60 :: number -- Minutes (from seconds)

-- README
-- If you mess with the stoppingRange you must make sure that the train can clear the stoppingRange of the previous point by messing
-- with speedTillMoving; you can leave speedTillStopped.
TManager._speedTillMoving = 50 :: number
TManager._speedTillStopped = 10 :: number

TManager.signals = {
	Stopped = TManager._signalStopped, -- when the train goes from moving to stopped, returns (empty return)
	Moving = TManager._signalMoving, -- when the train goes from stopped to moving, returns (empty return)
	StopUpdate = TManager._signalStopUpdate -- whenever the train is actually stopping, returns (currentStopInstance, nextStopInstance)
}


-- Sound animation sequences (you can mess with this.)
--[[
Just a side note, if you self a state being tampered with in this animation sequence such as self._running = false, do not touch it
or mess with the order of it. This whole system is a bit dodgy honestly and a little error will mess it up.

Also because the self._stopped variable is active past the velocity 10, do not place stops too close as it will not register it.
--]]

-- Animation Sequence moving
function TManager:_trainSequenceMoving()
	if TManager._running and not TManager._stopping then
		local MainLoco : any = TManager._carts[1]
		TManager._instance.Sounds.Moving:Play()
		MainLoco.Root.RailSqueal:Play()
	end
end

-- Animation Sequence engine start
function TManager:_engineSequenceStart() -- Literally just the start sequence
	if TManager._running == false and TManager._stopped then
		
		local MainLoco : any = TManager._carts[1]
		TManager._instance.Sounds.Starting:Play()
		task.wait(TManager._instance.Sounds.Starting.TimeLength)
		MainLoco.Root.Engine:Play()
		task.wait(2)
		TManager._instance.Sounds.Horn:Play()
		MainLoco.Root.Horn:Play()
		TManager._running = true
		TManager:_setTargetVelocity(TManager._maxVelocity)
		TManager._signalMoving:Wait()
		
	end
end

-- Animation Sequence Breaking
function TManager:_trainSequenceBreaking()
	
	if TManager._stopping and TManager._running then
		local MainLoco : any = TManager._carts[1]
		TManager:_setTargetVelocity(0)
		TManager._instance.Sounds.Brakes:Play()
		MainLoco.Root.RailSqueal:Stop()
		TManager._signalStopped:Wait()
		TManager._instance.Sounds.Brakes:Stop()
		TManager._instance.Sounds.Stopped:Play()
		task.wait(TManager._instance.Sounds.Stopped.TimeLength)
	end
end

-- Animation Sequence engine off
function TManager:_engineSequenceOff() -- Literally just the stop sequence
	if TManager._running == true and TManager._stopped then
		local MainLoco : any = TManager._carts[1]
		TManager._instance.Sounds.SteamRelease:Play()
		task.wait(TManager._instance.Sounds.SteamRelease.TimeLength)
		MainLoco.Root.Engine:Stop()
		TManager._stopping = false
		TManager._running = false
	end
end

-- Internal function for abstraction layer against CATROM module
function TManager:_generateSpline(points: {Vector3}, alpha: number?, tension: number?) -- Simply generates the spline points
	TManager._spline = CATROM.new(points, alpha or 0.5, tension or nil, false)
	TManager._spline:PrecomputeUnitSpeedData("now", "accurate")
	TManager._spline_totalLength = TManager._spline:SolveLength(0, 1)
	return true -- Loading menu if wanted
end

-- Internal function to add cargo_train model into module
function TManager:_setTrainModel(cargo : Model) -- Randomization logic goes here if wanted
	TManager._instance = cargo
	table.insert(TManager._carts, cargo["MainLocomotive"])
	for _, v in next, cargo:GetChildren() do
		if v.Name == "Flatcar" then
			table.insert(TManager._carts, v)
		end
	end
end

-- Internal function to load train model into desired location, can be changed.
function TManager:_loadTrainModel()
	TManager._instance.Parent = workspace
end

-- Internal function to unload train model into desired location, can be changed.
function TManager:_deloadTrainModel()
	TManager._instance.Parent = game.ReplicatedStorage
end

-- Internal function to override stops 
function TManager:_overrideStops(stops: {BasePart})
	TManager._stops = stops
end

-- Internally loops through carts and sets their positions, do not run this outside of the core loop
function TManager:_positionTrainCarts(tAlpha : number) -- Note: If PivotTo expensive to use, workspace:BulkMoveTo
	local currentLength = tAlpha * TManager._spline_totalLength
	for i, cart: Model in next, TManager._carts do
		local cSize = cart:GetExtentsSize()
		local offset = (i - 1) * cSize.Z
		local dist = currentLength - offset
		if dist < 0 then
			return
		end -- Basically so it doesn't go to something below zero
		local t = dist / TManager._spline_totalLength
		local Position = TManager._spline:SolvePosition(t, true)
		cart:PivotTo(
			CFrame.lookAlong(Position + Vector3.new(0, cSize.Y / 2, 0), TManager._spline:SolveTangent(t, true))
		)
	end
end

-- This is apart of the PID, it sets a target velocity and the train will increase/decrease to that. I recommend you do not touch this outside the module
function TManager:_setTargetVelocity(value: number) -- Yeah I could have used a math.clamp but if statements are faster
	TManager._targetVelocity = math.clamp(value, 0, TManager._maxVelocity)
end

-- Meat of the PID, can be modified to your liking. 
-- Warning: Velocity does not correlate to studs/second, it is a non-unitized value to represent the alpha of time [0, 100] -> [0, 1].
function TManager:_updatePID(dt: number)
	local new = TManager._velocity
	if TManager._velocity > TManager._targetVelocity then
		new = TManager._velocity - TManager._velocityDecay
	elseif TManager._velocity < TManager._targetVelocity then
		new = TManager._velocity + TManager._velocitySpeedup
	end
	TManager._velocity = math.clamp(new, 0, 100)
end

-- Internal function that handles the train stop logic
function TManager:_nextStop()
	if TManager._currentStop < #TManager._stops then
		TManager._currentStop += 1
	else
		TManager._currentStop = 1
	end
end

-- Internal function that updates the animation sequences and stops
function TManager:_updateSystem(tAlpha: number) -- This will include the stop logics and stuff
	local currentPos = TManager._spline:SolvePosition(tAlpha, true) :: Vector3
	local currentStop = TManager._stops[TManager._currentStop]
	if currentStop then
		if (currentStop.Position - currentPos).Magnitude <= TManager._stoppingRange and TManager._stopping == false and not TManager._stopped then
			-- Side note, this is like an animation, not everything is calculated, so tamper with this!
			-- Also this is where you put that it arrived at x station and other logic.
			TManager:_nextStop()
			TManager._signalStopUpdate:Fire(currentStop, TManager._stops[TManager._currentStop])
			
			TManager._stopping = true
			TManager:_trainSequenceBreaking()
			TManager:_engineSequenceOff()
			task.wait(TManager._timeBetweenStops)
			if TManager._stopped then
				TManager:_engineSequenceStart()
				TManager:_trainSequenceMoving()
			end
		end
	end
end

-- Internal function that handles train state based on revelant data
function TManager:_updateState()
	if TManager._velocity <= TManager._speedTillStopped then
		if not TManager._stopped then
			TManager._signalStopped:Fire()
		end
		TManager._stopped = true
	elseif TManager._velocity >= TManager._speedTillMoving then
		if TManager._stopped then
			TManager._signalMoving:Fire()
		end
		TManager._stopped = false
	end
end

function TManager:_disableAllSounds()
	local MainLoco : any = TManager._carts[1]
	TManager._instance.Sounds.Moving:Stop()
	MainLoco.Root.RailSqueal:Stop()
	MainLoco.Root.Engine:Stop()
end

-- Internal function to handle the train reaching the end of the route
function TManager:_finishedRoute()
	TManager._heartbeatConnection:Disconnect()
	TManager._elapsedTime = 0
	
	TManager._targetVelocity = 0
	TManager._velocity = 0
	TManager._currentStop = 1
	
	TManager._stopping = false
	TManager._running = false
	TManager._stopped = true
	TManager:_disableAllSounds()
	TManager:_deloadTrainModel()
	task.delay(TManager._timeBetweenNextTrain, function()
		TManager:_startTrainSequence()
	end)
end

-- Internal function to start the train logic
function TManager:_connectToHeartbeat() -- Connects the entire logic
	TManager._heartbeatConnection = RS.Heartbeat:Connect(function(dt)
		local tAlpha = TManager._elapsedTime / TManager._fixedTotalTime 
		
		if tAlpha >= 1 then -- Could use epsilon check here instead, might be better
			TManager:_finishedRoute()
			return
		end

		TManager:_updateState()
		TManager:_updatePID(dt) -- mini pid 
		
		TManager:_updateSystem(tAlpha) -- yeah
		TManager:_positionTrainCarts(tAlpha)
		

		TManager._elapsedTime += (dt * (TManager._velocity/TManager._maxVelocity)) -- Rate of time I was talking about above
	end) 
end

-- Path trace of the entire route in the special color blue.
function TManager:debugRoute()
	local instanceBin = {}
	for i=0, 99 do
		local pos : Vector3 = TManager._spline:SolvePosition(i/100) :: Vector3
		local pos2 : Vector3 = TManager._spline:SolvePosition((i+1)/100) :: Vector3
		local newInst = Instance.new("LineHandleAdornment")
		newInst.Adornee = workspace
		newInst.Length = (pos2 - pos).Magnitude
		newInst.CFrame = CFrame.new(pos, pos2)
		newInst.Thickness = 2
		newInst.Parent = workspace
		table.insert(instanceBin, newInst)
	end
	return function ()
		for i, v in next, instanceBin do
			v:Destroy()
		end
	end
end

function TManager:_startTrainSequence()
	TManager:_loadTrainModel()

	TManager:_connectToHeartbeat()
	TManager:_engineSequenceStart()
	TManager:_trainSequenceMoving()
end

-- Public function to start the train and register the points. Order matters in stop_points and spline_points

function TManager:start(spline_points: {BasePart}, stop_points: {BasePart}, cargo_train: Model, alpha: number?, torsion: number?)
	
	
	
	local cordPoints = {}
	for i, v in next, spline_points do
		table.insert(cordPoints, v.Position)
	end
	TManager:_generateSpline(cordPoints, alpha, torsion)
	TManager:_setTrainModel(cargo_train)
	
	if TManager._overrideSpeedToTotalTime then
		TManager._fixedTotalTime = TManager._spline:SolveLength(0, 1) / TManager._fixedStudsVelocity -- Im thinking holdon
	end
	
	TManager:_overrideStops(stop_points)
	TManager:_startTrainSequence()
	
end


return TManager
