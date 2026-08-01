--29/07/2026

--[Services]


local Energy = {}
Energy.__index = Energy

function Energy.new(template)
	local self = setmetatable({}, Energy)
	
	self.min = template.min
	self.max = template.max
	self.regen = template.regen
	self.value = template.min
	
	return self
end

function Energy:Regen()
	self:Change(self.regen)
	return self.value
end

function Energy:Use(delta: number)
	if delta > self.value then
		return warn("Not enough energy.")
	end
	self:Change(-delta)
	return self.value
end

function Energy:Change(delta: number)
	self.value = math.clamp(self.value + delta, self.min, self.max)
	return self.value
end

function Energy:GetValue()
	return self.value
end

return Energy