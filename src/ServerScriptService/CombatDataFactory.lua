--Services
local LogService = game:GetService("LogService")

local CombatData = {}
CombatData.__index = CombatData

--Constructor
function CombatData.new(entities)
	local self = setmetatable({}, CombatData)
	
	self.currentTurn = 0
	self.entities = entities
	self.turnOrder = {}
	
	return self
end

function CombatData:Sort()
	table.sort(self.turnOrder, function(a, b)
		return a:GetValue() > b:GetValue()
	end)

	LogService:Info('Combat order sorted.')
	print(self.turnOrder)
end

function CombatData:ClearTurnOrder()
	self.turnOrder = {}
end

function CombatData:CreateTurnOrder()
	self:ClearTurnOrder()
	
	for _, entity in pairs(self.entities) do
		local speedDice = entity:GetSpeedDice()
		for _, speedDie in pairs(speedDice) do
			table.insert(self.turnOrder, speedDie)
		end
	end
	
	self:Sort()
end

--[GETTER]
function CombatData:GetTurnOrder()
	return self.turnOrder
end

function CombatData:GetCurrentTurn()
	return self.currentTurn
end

function CombatData:IncrementTurn()
	self.currentTurn += 1
end

return CombatData