--// Base
--// Use CollectionService
--[[
.Loop (Allows tag function to be ran in a loop, requires a signal.)
.Tag (Puts tag into tag table. Can be instanced, meaning it runs everytime in game instance tag is created)
:BulkLoadTags(tags, functions)
]]
local CS = game:GetService("CollectionService")

type TagMeta = {
	tag_id: string,
	tag_instanced: boolean?,
	[any] : any
}

type TagData = {
	tag_id: string,
	tag_instanced: boolean?,
	signals : {
		Added: RBXScriptSignal,
		Removed: RBXScriptSignal
	},
	[any]: any
}

local isf = {
	tags = {}
}

function isf.new(data: TagMeta) : TagData
	if data.tag_instanced then
		data.signals = {
			Added = CS:GetInstanceAddedSignal(data.tag_id),
			Removed = CS:GetInstanceRemovedSignal(data.tag_id)
		}
	end
	
	function data:query()
		return CS:GetTagged(data.tag_id)
	end
	
	isf.tags[data.tag_id] = data
	return data
end

function isf:query(tag_id: string) : {Instance}
	return CS:GetTagged(tag_id)
end

function isf:queries(...)
	local index = 0
	local tag_instances = {}
	for i, tag in next, {...} do
		tag_instances[i] = CS:GetTagged(tag)
	end
	return function()
		index = index + 1
		local packed = {}
		for i, x in next, tag_instances do
			packed[i] = x[index]
		end
		return #packed > 0 and table.unpack(packed) or nil
	end
end

function isf.loop(sequence: {}, event: RBXScriptSignal) : RBXScriptConnection
	return event:Connect(function(...)
		for _, v in next, sequence do
			local tag = isf.tags[v]
			if tag["update"] then
				tag:update(...)
			end
		end
	end)
end

return isf