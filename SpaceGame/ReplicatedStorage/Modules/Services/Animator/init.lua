local Animator = {}
local TweenStyles = require(script.TweenStyles)

function Animator.createRef(object, isPath)
	local reference = isPath and object or Instance.new(object)
	
	local bindable = Instance.new("BindableEvent")
	
	local event = bindable.Event
	local isModel = reference:IsA("Model")
	
	local function setCFrame()
			
	end
	local function getCFrame()
		
	end
end

return Animator