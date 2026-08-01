local CardEffect = {}
CardEffect.__index = CardEffect

function CardEffect.new()
	local self = setmetatable({}, CardEffect)
	
	self.triggers = {}
	
	return self
end

function CardEffect:Add(triggerName, onTriggerFn)
	--Ensures that there is a list for the given trigger so the function can be added to it.
	if not self.triggers[triggerName] then
		self.triggers[triggerName] = {}
	end

	--Calls the function when the trigger is called.
	table.insert(self.triggers[triggerName], onTriggerFn)
end
function CardEffect:Apply(owner)
	self.onTriggerFn(owner)
end

return CardEffect