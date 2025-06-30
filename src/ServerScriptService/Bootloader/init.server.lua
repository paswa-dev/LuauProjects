local Utilites = script.Parent.Utilities
local RP = game:GetService("ReplicatedStorage")
local Remotes = RP.Remotes
local Modules = RP.Modules

local function parse(base, text: string)
	local success, result = pcall(function()
		for _, Entry in next, text:split("/") do
			base = base[Entry]
		end
		return base
	end)
	return result
end

function _G.get(name, basepath: Instance?)
	local file = parse(basepath or Utilites, name) --// May want to set 2nd param to true, but modules will need to be case sensetive (idk how to spell)
	if file then
		local Loaded = require(file) 
		return Loaded
	else
		warn("Could not retrieve: " .. name)
	end
	return nil
end

function _G.fetch(name)
	local file = parse(Modules, name) --// May want to set 2nd param to true, but modules will need to be case sensetive (idk how to spell)
	if file then
		local Loaded = require(file) 
		return Loaded
	else
		warn("Could not retrieve: " .. name)
	end
	return nil
end

function _G.remote(name)
	return parse(Remotes, name)
end


--// We need a way to execute things in order. Like core scripts

local function main()
	local Modules = script:GetDescendants()
	table.sort(Modules, function(instance1, instance2)
		local Order1 = instance1:GetAttribute("order") or 1000
		local Order2 = instance2:GetAttribute("order") or 1000
		return Order1 < Order2
	end)
	for _, Module in next, Modules do
		if Module:IsA("ModuleScript") then
			local Loaded = require(Module)
			if Loaded["init"] then
				Loaded.init()
			end
		end
	end
end


main()