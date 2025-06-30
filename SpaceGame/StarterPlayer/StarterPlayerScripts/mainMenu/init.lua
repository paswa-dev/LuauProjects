local get = _G.get


local Plr = game.Players.LocalPlayer
local WCamera = workspace.CurrentCamera
local Gui = Plr.PlayerGui

local Animator = get "Services/Animator"
local Garbage = get "Classes/Garbage"

local Iris = (get "Shared/Iris").Init()
local Bin = Garbage.new()

local Camera = Animator.new(workspace.CurrentCamera)
local Cutscene = require(script:WaitForChild("Cutscene"))
local MainMenu = Gui:WaitForChild("MainMenu")

local CryoExited = false
local notesOpen = false

local function Notes()
	local Window = Iris.Window({"Development Notes"})
		if Window.closed() then
			notesOpen = false
		end
		Iris.Text(
			{[[
Update Notes (2/12/2024 - Current)
- Completed Menu + Implemented Iris into main screen.
- Visual Debugging
- Jakey Gizmo Library importation.
- Net framework completed.

Development todo list (2/12/2024 12:51 AM)
1. Main Menu ( Camera preview thingy )
2. UI with Iris (inventory mainly)
3. add weapons (build tool, shotgun, rocket launcher, pistol, and a glue tool)
4. damage tracker (module that handles damage)
5. fix zombies (make AI)
7. loot (link data to instance)
8. Alpha Test
			
			]]}
		)
	Iris.End()
end

local function toggleNotes()
	if not notesOpen then
		notesOpen = true
		Iris:Connect(Notes)
	end
end

local function onCryoExit()
	if not CryoExited then
		CryoExited = true
		Bin:trash()
		Camera:PlaySequence("PodRelease")
		Camera.finished.Event:Wait()
		WCamera.CameraType = Enum.CameraType.Custom
		if notesOpen then toggleNotes() end
		MainMenu.Enabled = false
	end
end

local function main()
	Camera:LoadSequence("PodRelease", Cutscene, 1, 1000, true)
	WCamera.CameraType = Enum.CameraType.Scriptable
	WCamera.CFrame = workspace:WaitForChild("SpawnPods"):WaitForChild("Tube").Camera.CFrame
	Bin.NotesClick = MainMenu.Notes.MouseButton1Click:Connect(toggleNotes)
	Bin.SpawnClicked = MainMenu.Spawn.MouseButton1Click:Connect(onCryoExit)
end

return {
	init = main
}