local QaudSplice = Vector3.new(2,2,1)
local Pos, Neg = 1, 2

local QaudrantHash = {
	BottomLeft = 1,
	BottomRight = 2,
	TopLeft = 3,
	TopRight = 4
}

local Bounds = {
	[QaudrantHash.BottomLeft] = Vector3.new(Neg, Neg, 0),
	[QaudrantHash.BottomRight] = Vector3.new(Pos, Neg, 0),
	[QaudrantHash.TopLeft] = Vector3.new(Neg, Pos, 0),
	[QaudrantHash.TopRight] = Vector3.new(Pos, Pos, 0)
}

local Map = {
	[Pos] = {
		[Pos] = QaudrantHash.TopRight,
		[Neg] = QaudrantHash.TopLeft
	},
	[Neg] = {
		[Pos] = QaudrantHash.BottomRight,
		[Neg] = QaudrantHash.BottomLeft
	}
}

local function RelativeToCFrame(_CFrame, Position)
	return _CFrame:ToWorldSpace(CFrame.new(Position))
end

local function MakePart(_CFrame, Size)
	local Part = Instance.new("Part")
	Part.CFrame = _CFrame
	Part.Size = Size
	Part.Anchored = true
	Part.Parent = workspace.Destructable
	return Part
end

local function Cut(part, splice_vector)
	local Parts = {}
	local _Size = part.Size
	local _Position = part.Position - (_Size / 2)
	local _Split = _Size / splice_vector
	local _CFrame = part.CFrame

	local function RelativeTo(WorldPoint)
		return RelativeToCFrame(_CFrame, WorldPoint-part.Position)
	end

	for x=1, splice_vector.X do
		for y=1, splice_vector.Y do
			for z=1, splice_vector.Z do
				local Size = _Split
				local Point = Vector3.new(x, y, z) * Size
				local WorldPoint = (Point + _Position) - (Size/2)
				table.insert(Parts, MakePart(RelativeTo(WorldPoint), Size))
			end
		end
	end
	return Parts
end

local function FindQaudrant(center, point)
	local X = (point.X >= center.X) and Pos or Neg
	local Y = (point.Y >= center.Y) and Pos or Neg
	return Map[X][Y]
end

local function isClose(center, position, radius)
	return (position - center).Magnitude <= radius
end

local QuadTree = {}

function QuadTree.new(part, parent)
	local config = {}
	config.Parent = parent
	config.ChildrenData = Cut(part, QaudSplice)
	config.Children = table.create(4)
	config.P1 = part.Position - (part.Size/2)
	config.P2 = part.Position + (part.Size/2)
	config.Center = part.Position
	config.Depth = parent and parent.Depth + 1 or 0
	part:Destroy()
	return setmetatable(config, {__index = QuadTree})
end

function QuadTree:GetFirst()
	if self.Depth == 0 then
		return self
	else
		return self.Parent:GetFirst()
	end
end

function QuadTree:ClosestNodes(position, radius)
	local Selected = {}
	for _, Node in next, self.Children do
		if (Node.Center - position).Magnitude <= radius then
			table.insert(Selected, Node)
		end
	end
	return Selected
end

function QuadTree:ClosestNodeDatas(position, radius)
	local Selected = {}
	for _, Part in next, self.ChildrenData do
		if (Part.Position - position).Magnitude <= radius then
			table.insert(Selected, Part)
		end
	end
	return Selected
end

function QuadTree:ClosestSubNodes(position, radius)
	local Selected = {}
	for Quadrant, Part in next, self.ChildrenData do
		local Node = self.Children[Quadrant]
		if Node then
			for _, FoundNode in next, Node:ClosestSubNodes(position, radius) do
				table.insert(Selected, Node)
			end
		end
		if Part ~= nil then
			if (Part.Position - position).Magnitude <= radius then
				table.insert(Selected, Node)
			end
		end
		
	end
	return Selected
end

function QuadTree:ClosestSubNodeDatas(position, radius)
	local Selected = {}
	for Quadrant, Part in next, self.ChildrenData do
		local Node = self.Children[Quadrant]
		if Node then
			for _, FoundPart in next, Node:ClosestSubNodeDatas(position, radius) do
				table.insert(Selected, FoundPart)
			end
		end
		if Part ~= nil then
			if (Part.Position - position).Magnitude <= radius then
				table.insert(Selected, Part)
			end
		end
	end
	return Selected
end

function QuadTree:ClosestSingleNode(position, depth)
	local Quadrant = FindQaudrant(self.Center, position)
	if (self.Depth == (depth + 1)) or (self.Children[Quadrant] == nil) then
		return self
	end
	return self.Children[Quadrant]:ClosestSingleNode(position, depth)
end

function QuadTree:ClosestSingleNodeData(position, depth)
	local Node = self:ClosestSingleNode(position, depth)
	local Best = nil
	local Magnitude = nil
	for _, Data in next, Node.ChildrenData do
		if not Best then Best = Data; Magnitude = (Data.Position - position).Magnitude else
			local Dist = (Data.Position - position).Magnitude
			if Dist < Magnitude then
				Magnitude = Dist
				Best = Data
			end
		end
	end
	return Best
end

function QuadTree:GetNodeDatasWithinRadius(position, depth, radius)
	local LastNode = self:ClosestSingleNode(position, depth)
	local Nodes = {}
	local Current = LastNode
	while true do
		for _, Part in next, Current:ClosestSubNodeDatas(position, radius) do
			table.insert(Nodes, Part)
		end
		if Current.Parent == nil then break end
		Current = Current.Parent
	end
	return Nodes
end

function QuadTree:GetNodesWithinRadius(position, radius, depth)
	local LastNode = self:ClosestSingleNode(position, depth)
	local Nodes = {}
	local Current = LastNode
	while true do
		for _, Node in next, Current:ClosestSubNodes(position, radius) do
			table.insert(Nodes, Node)
		end
		Current = Current.Parent
		if Current.Parent == nil then break end
	end
	return Nodes
end

function QuadTree:Insert(position, depth)
	if self.Depth == (depth + 1) then return end
	local Qaudrant = FindQaudrant(self.Center, position)
	if self.Children[Qaudrant] then
		self.Children[Qaudrant]:Insert(position, depth)
	else
		self.Children[Qaudrant] = QuadTree.new(self.ChildrenData[Qaudrant], self)
		self.Children[Qaudrant]:Insert(position, depth)
	end
end

function QuadTree:InsertToRadius(position, depth, radius)
	local Rand = Random.new()
	for i=1, 10 do
		local NewPosition = position + (Rand:NextUnitVector() * math.random(0, radius))
		self:Insert(NewPosition, depth)
	end
	self:Insert(position, depth)
end

return QuadTree
