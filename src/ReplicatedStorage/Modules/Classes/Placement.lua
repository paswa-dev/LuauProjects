local RS = game:GetService("RunService")
local CAMERA = workspace.CurrentCamera
local PLAYER = game.Players.LocalPlayer

local module = {}
local highlight = {}
local mainMT = {__index = module}
local secondaryMT = {__index = highlight}

--// Constructors
local function setupNewRaycastParam(...)
	local new = RaycastParams.new()
	new.FilterDescendantsInstances = {...}
	new.FilterType = Enum.RaycastFilterType.Exclude
	return new
end

local function ChangePartSpacials(part, boolean)
	part.CanCollide = boolean
	part.CanQuery = boolean
	part.CanTouch = boolean
	part.Transparency = 0.5
end

local function setCFrame(object, cf)
	if object:IsA("Model") then
		object:SetPivot(cf)
	else
		object.CFrame = cf
	end
end

local function calibrateNewCFrame(object, cframe, extra_rotation)
	local Size : Vector3?
	if object:IsA("Model") then
		Size = object:GetExtentsSize()
	else
		Size = object.Size
	end
	local newCF = cframe * CFrame.Angles(-math.pi/2, math.rad(extra_rotation), 0) * CFrame.new(0, object.Size.Y/2, 0)
	return object.CFrame:Lerp(newCF, 0.6)
end

function module.new(folder)
	local data = {
		folder = folder,
		selection = nil,
		outOfRange = false,
		currentMaxDistance = 30,
		highlight = highlight.new(),
		_subData = {
			rotation = 0
		}
	}
	--// Reconsider these, overhead call might be a waste. Just set them as nil?
	function data.onCancel() end
	
	function data.onConfirm() end
	
	function data.onUpdate() end
	
	return setmetatable(data, mainMT)
end

function highlight.new()
	local object_data = {
		Adornee = nil,
		OutlineColor = Color3.new(255, 255, 255),
		FillColor = Color3.new(0, 255, 0),
		FillTransparency = 0.45,
		OutlineTransparency = 0,
		DepthMode = Enum.HighlightDepthMode.Occluded,
		Parent = workspace,
		_subData = {
			CachedHighlight = nil,
		},
	}
	
	return setmetatable(object_data, secondaryMT)
end

--// Methods
function highlight:build()
	if self._subData.CachedHighlight then self:reload(); return end --// If highlight exist just reload and return.
	local Object = Instance.new("Highlight")
	for property, value in next, self do
		if property ~= "_subData" then
			Object[property] = value
		end
	end
	self._subData.CachedHighlight = Object
	return Object
end

function highlight:reload()
	if not self._subData.CachedHighlight then self:build(); return end --// Vice versa of above
	for property, value in next, self do
		if property ~= "_subData" then
			self._subData.CachedHighlight[property] = value
		end
	end
end

function highlight:hide() --// Waste of performance to reload everything, just reload adornee
	self.Adornee = nil
	if self._subData.CachedHighlight then
		self._subData.CachedHighlight.Adornee = nil
		self._subData.CachedHighlight.Parent = nil
	end
end

--[[
TODO:
1. Change RS:Bind to a connection, jsut disable it and store it in self._subData

]]

function module:Place(name)
	if self.folder[name] and PLAYER.Character then
		self.selected = self.folder[name]:Clone()
		self.highlight.Adornee = self.selected
		self.selected.Parent = workspace
		self._subData.Params = setupNewRaycastParam(self.selected, PLAYER.Character)
		ChangePartSpacials(self.selected)
		RS:BindToRenderStep("BuildUpdate", Enum.RenderPriority.First.Value, function()
			if PLAYER.Character == nil then
				self:Cancel()
				return
			else
				local Raycast = workspace:Raycast(
					CAMERA.CFrame.Position, 
					CAMERA.CFrame.LookVector * self.currentMaxDistance,
					self._subData.Params
				)
				if Raycast then
					if self.selected.Parent == nil then self.selected.Parent = workspace end
					setCFrame(
						self.selected, 
						calibrateNewCFrame(
							self.selected, 
							CFrame.new(Raycast.Position, Raycast.Position + Raycast.Normal),
							self._subData.rotation
						)
					)
				else
					self.selected.Parent = nil
				end
			end
		end)
		self.highlight:build()
	end
end

function module:Cancel()
	if not self.selected then return end
	self.onCancel(self.selected.Name)
	RS:UnbindFromRenderStep("BuildUpdate")
	self.highlight:hide()
	self.selected:Destroy()
	self.selected = nil
end

function module:Confirm()
	if not self.selected then return end
	self.onConfirm(self.selected.Name)
	RS:UnbindFromRenderStep("BuildUpdate")
	self.highlight:hide()
	self.selected:Destroy()
	self.selected = nil
end



return module
