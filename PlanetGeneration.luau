---// Creates a new planet
local planet = {}

local sides = {
	Vector3.FromNormalId(Enum.NormalId.Front),
	Vector3.FromNormalId(Enum.NormalId.Back),
	Vector3.FromNormalId(Enum.NormalId.Left),
	Vector3.FromNormalId(Enum.NormalId.Right),
	Vector3.FromNormalId(Enum.NormalId.Top),
	Vector3.FromNormalId(Enum.NormalId.Bottom)
}

local function generateMesh(mesh: EditableMesh, vertices, triangles)
	local id = #mesh:GetVertices()
	for i, vertex in next, vertices do
		mesh:AddVertex(vertex)
	end
	
	for i=0, #triangles, 6 do
		mesh:AddTriangle(triangles[i] + id, triangles[i + 1] + id, triangles[i + 2] + id)
		mesh:AddTriangle(triangles[i + 3] + id, triangles[i + 4] + id, triangles[i + 5] + id)
	end
	return id
end

function planet.new(resolution, position)
	local data = {}
	data.resolution = resolution
	data.position = position or Vector3.zero
	
	return setmetatable(data, {__index = planet})
end

function planet:generateside(mesh, direction, resolution)
	local meshIndex = 0
	local vertices = {}
	local triangles = {}
	local up = direction

	local axisA = Vector3.new(up.Y, up.Z, up.X)
	local axisB = up:Cross(axisA)
	
	for y = 0, resolution - 1 do
		for x = 0, resolution - 1 do
			local i = (x + (y * resolution)) + 1
			local percent = Vector2.new(x, y) / (resolution - 1)
			local positionBox = up + ((percent.X - .5) * 2 * axisA) + ((percent.Y - .5) * 2 * axisB)
			local positionCircle = positionBox.Unit
			vertices[i] = positionCircle
			if x ~= (resolution - 1) and y ~= (resolution - 1) then
				triangles[meshIndex] = i
				triangles[meshIndex + 1] = i + resolution + 1
				triangles[meshIndex + 2] = i + resolution

				triangles[meshIndex + 3] = i
				triangles[meshIndex + 4] = i + 1
				triangles[meshIndex + 5] = i + resolution + 1

				meshIndex += 6
			end

		end
	end
	return generateMesh(mesh, vertices, triangles)
end

--// So the reason for 6, is because we want a triangle for x and y, which is 3 + 3 = 6

function planet:construct()
	local Mesh = Instance.new("EditableMesh")
	for _, v in next, sides do
		self:generateside(Mesh, v, self.resolution)
	end
	local part = Instance.new("MeshPart")
	Mesh.Parent = part
	part.Anchored = true
	part.Position = self.position
	part.Size = Vector3.one
	part.Parent = workspace
	return Mesh, part
end


task.wait(2)
local newPlanet = planet.new(41, Vector3.new(0, 100, 0))
local Mesh, Part = newPlanet:construct()
Part.Color = Color3.new(0.341176, 0.364706, 0.392157)
task.wait(4)
local Scroll = Random.new():NextNumber(0, 1000000)
for i, v in next, Mesh:GetVertices() do
	local Position = Mesh:GetPosition(v)
	local Noise = math.noise(
		(((Position.X * 4) + Scroll) / 50) * 50, 
		(((Position.Y * 4) + Scroll) / 50) * 50,  
		(((Position.Z * 4) + Scroll) / 50) * 50
	) * 10
	local NewPoint = Position * 200
	NewPoint += Position * Noise
	Mesh:SetPosition(v, NewPoint)
end
print "Altered Existing Mesh"