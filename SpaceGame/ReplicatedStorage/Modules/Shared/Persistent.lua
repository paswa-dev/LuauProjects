--// Persistent Data on player stored here
local ps = {
	data = {}
}

function ps.push(k, v) -- Overrides regardless
	ps.data[k] = v
end

function ps.insert(k, v)
	if ps.data[k] then
		table.insert(ps.data[k], v)
	end
end

function ps.softpush(k, v) -- Creates a new variable, without overriding existing
	if ps.data[k] == nil then
		ps.data[k] = v
	end
end

function ps.hardpush(k, v) -- Overrides existing value
	if ps.data[k] then
		ps.data[k] = v
	end
end

function ps.get(k) -- Just gets it really.
	return ps.data[k]
end

function ps.merge(dict) -- Merge two dictionaries together
	for i, v in next, dict do
		ps.softpush(i, v)
	end
end

return ps