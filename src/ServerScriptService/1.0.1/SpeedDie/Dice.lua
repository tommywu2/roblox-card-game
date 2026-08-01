--29/07/2026

local Dice = {}
Dice.__index = Dice

function Dice.new(template)
	local self = setmetatable({}, Dice)
	
	self.min = template.min
	self.max = template.max
	self.value = nil
	
	return self
end

function Dice:Roll()
	self.value = math.random(self.min, self.max)
	return self.value
end

function Dice:GetValue()
	return self.value
end

return Dice