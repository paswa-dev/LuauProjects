local observer = {}
local observerConnection = {}
local observerEvent = {}

function observer.new(_function)
	local data = {}
	data.Event = observerEvent.new()
	
	task.spawn(_function, data.Event)
	
	return setmetatable({}, {__index = observerEvent})
end

function observer:Subscribe(_callback, _final_callback)
	if _callback then
		table.insert(self.Event.callbacks, _callback)
	else
		table.insert(self.Event.final_callbacks, _final_callback)
	end
end

--// Event

function observerEvent.new()
	local data = {
		callbacks = {},
		final_callbacks = {}
	}
	
	return setmetatable(data, {__index = observerEvent})
end

function observerEvent:Fire(...)
	for _, callback in next, self.callbacks do
		task.spawn(callback, ...)
	end
end

function observerEvent:Final(...)
	for _, callback in next, self.final_callbacks do
		task.spawn(callback, ...)
	end
end

--// Connection
--// Add UnSubscribe later

return observer