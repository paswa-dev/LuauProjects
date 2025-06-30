local PLAYERS = game:GetService("Players")
local RS = game:GetService("RunService")
local GET = _G.get
local BASE = GET "Classes/Behavior/Base"
local NET = GET "Data/Net"

local PLAYER = PLAYERS.LocalPlayer

local WEAPON = {}

function WEAPON.new(model)
	local Behavior = BASE.extend()
	local S_CORE = Behavior._SGROUP

	

	Behavior:insertSpring("UpDown", 0, 5, 1)
	Behavior:insertSpring("Recoil", Vector3.zero, 5, 1)

	WEAPON:insertUpdate("Position", function()
		--// Updates Viewmodel/Model Position
	end)

	WEAPON:insertUpdate("Parameters" function()
		--// Updates Logic
	end)

	return Behavior
end

return WEAPON