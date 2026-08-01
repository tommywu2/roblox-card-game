--25/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]


--[Main]
local StatusEffect = {}
StatusEffect.__index = StatusEffect

--[Constructor]
function StatusEffect.new(name, description, stacks, events)
	local self = setmetatable({}, StatusEffect)
	
	self.name = name
	self.description = description --Optional description for UI display.
	self.stacks = stacks
	
	self.events = events
	
	return self
end

--[Functions]
function StatusEffect:ChangeStacks(delta: number)
	self.stacks += delta
end

--[Getters]
function StatusEffect:GetName()
	return self.name
end

function StatusEffect:GetDescription()
	return self.description
end

function StatusEffect:GetStacks()
	return self.stacks
end

--[Setters]
function StatusEffect:SetStacks(amount: number)
	self.stacks = amount
end

--[Events]
function StatusEffect:FireEvent(eventName, data)
	for _, fn in self.events[eventName] do
		fn(self, data)
	end
end

return StatusEffect