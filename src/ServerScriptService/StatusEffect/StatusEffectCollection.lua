--25/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local StatusEffectFactory = require(ServerScriptService.StatusEffect.StatusEffectFactory)

local StatusEffectCollection = {}
StatusEffectCollection.__index = StatusEffectCollection

function StatusEffectCollection.new()
	local self = setmetatable({}, StatusEffectCollection)
	
	self.statusEffects = {}
	
	return self
end

function StatusEffectCollection:Add(statusEffectID: number, stacks: number)
	if not self.statusEffects[statusEffectID] then
		self.statusEffects[statusEffectID] = StatusEffectFactory.CreateStatusEffect(statusEffectID, 0)
	end
	
	self.statusEffects[statusEffectID]:ChangeStacks(stacks)
end

function StatusEffectCollection:Remove(statusEffectID)
	self.items[statusEffectID] = nil
end

function StatusEffectCollection:Has(statusEffectID)
	if self.items[statusEffectID] then
		return true
	end

	return false
end

function StatusEffectCollection:Get(statusEffectID)
	return self.items[statusEffectID]
end

function StatusEffectCollection:FireEvent(eventName, data)
	for _, statusEffect in pairs(self.statusEffects) do
		statusEffect:FireEvent(eventName, data)
	end
end

return StatusEffectCollection