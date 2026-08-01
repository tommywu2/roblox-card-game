--12/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--[Modules]
local PileFactory = require(ServerScriptService.PileFactory)

--[]
local SpeedDie = setmetatable({}, { __index = PileFactory })
SpeedDie.__index = SpeedDie

--[Types]
type SpeedDie = typeof(SpeedDie)

--[Constructor]
function SpeedDie.new(owner, config)
	local self = setmetatable({}, SpeedDie)
	
	self.owner = owner
	self.baseMin = config.roll.min
	self.baseMax = config.roll.max
	
	self.roll = {
		min = config.roll.min,
		max = config.roll.max,
		current = config.roll.min,
	}
	
	self.energy = {
		min = config.energy.min,
		max = config.energy.max,
		gain = config.energy.gain,
		current = config.energy.min,
	}
	
	self.assignedPile = PileFactory.new()
	self.archivedPile = PileFactory.new()
	
	self.targetSpeedDie = nil
	
	self.locked = false
	
	return self
end

--[Energy]
function SpeedDie:ChangeEnergy(delta: number)
	self.energy.current = math.clamp(self.energy.current + delta, self.energy.min, self.energy.max)
end

function SpeedDie:HasEnergy(amount: number)
	return self.energy.current >= amount
end

function SpeedDie:GetEnergy()
	return self.energy.current
end

--[Logic]
function SpeedDie:Roll()
	self.roll.current = math.random(self.roll.min, self.roll.max)
	
	--Logging
	LogService:Output(`{self.owner.name} speed die rolled {self.roll.current}`)
end

function SpeedDie:Reset()
	self:Unlock()
	self:ClearTargetSpeedDie()
end

--[Locking]
function SpeedDie:Lock()
	self.locked = true
end

function SpeedDie:Unlock()
	self.locked = false
end

function SpeedDie:IsLocked()
	return self.locked
end

--[Targetting]
function SpeedDie:ClearTargetSpeedDie()
	self.targetSpeedDie = nil
end

--[Cards]
function SpeedDie:AssignCard(card)
	if self:IsLocked() then warn("SpeedDie is locked.") return end
	if not self:HasEnergy(card.cost) then warn("SpeedDie has insufficient energy.") return end
	
	self:ChangeEnergy(-card.cost)
	self.assignedPile:Add(card)
end

function SpeedDie:UnassignCard(instanceID)
	if self:IsLocked() then warn("SpeedDie is locked.") return end
	
	local card = self.assignedPile:Get(instanceID)
	if not card then return end
	
	self.assignedPile:Remove(instanceID)
	self:ChangeEnergy(card.cost)
	return card
end

function SpeedDie:ArchiveCard(card)
	self.assignedPile:Remove(card.instanceID)
	self.archivedPile:Add(card)
end

--[Helpers]
function SpeedDie:GetValue()
	return self.roll.current
end

function SpeedDie:SetValue(value: number)
	self.roll.current = value
	
	--Logging
	LogService:Output(`{self.owner.name} speed die value set to {self.roll.current}`)
end

function SpeedDie:SetRange(min: number, max: number)
	self.roll.min = min
	self.roll.max = max
	LogService:Output(`{self.owner.name} speed die range set to {self.roll.min}, {self.roll.max}`)
end

function SpeedDie:GetOwner()
	return self.owner
end

function SpeedDie:GetTargetSpeedDie()
	return self.targetSpeedDie
end

function SpeedDie:SetTargetSpeedDie(target: SpeedDie)
	self.targetSpeedDie = target
end

function SpeedDie:GetAssignedPile()
	return self.assignedPile
end

function SpeedDie:GetArchivedPile()
	return self.archivedPile
end



function SpeedDie:GainEnergy()
	self:ChangeEnergy(self.energy.gain)
end

return SpeedDie