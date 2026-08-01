--12/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local ContainerFactory = require(ServerScriptService.ContainerFactory)
local StatusEffectLibrary = require(ServerScriptService.StatusEffectLibrary)

local StatusEffectCollection = {}
StatusEffectCollection.__index = StatusEffectCollection

--[Constructor]
function StatusEffectCollection.new(owner)
	local self = setmetatable(ContainerFactory.new(), StatusEffectCollection)
	
	self.owner = owner
	
	return self
end

--[Logic]
function StatusEffectCollection:Add(statusEffectID: number, amount: number)
	--Prevent negative status effects.
	if amount <= 0 then return end
	
	if self:Has(statusEffectID) then
		local instance = self:Get(statusEffectID)
		instance:ChangeStacks(amount)
		
		return instance, "stacked"
	else
		local instance = StatusEffectLibrary.new(statusEffectID, amount)
		self.items[statusEffectID] = instance
		
		return instance, "created"
	end
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

function StatusEffectCollection:ProcessEvent(triggerName, context)
	for _, statusEffect in ipairs(self.items) do
		statusEffect:FireEvent(triggerName, context)
		
		if statusEffect:GetStacks() <= 0 then
			self:Remove(statusEffect:GetID())
		end
	end
end

return StatusEffectCollection