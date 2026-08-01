--29/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local Dice = require(ServerScriptService.Dice)
local Energy = require(ServerScriptService.Energy)
local Pile = require(ServerScriptService.Pile)

local SpeedDice = {}
SpeedDice.__index = SpeedDice

function SpeedDice.new(template)
	local self = setmetatable({}, SpeedDice)
	
	self.dice = Dice.new(template.dice)
	self.energy = Energy.new(template.energy)
	self.pendingEnergyCost = 0
	
	self.assignedCards = Pile.new()
	self.usedCards = Pile.new()
	
	self.targetSpeedDie = nil
	
	return self
end

--Update pending energy cost whenever a card is assigned, unassigned, or the cost of a card changes.
function SpeedDice:UpdatePendingEnergyCost()
	local pendingEnergyCost = 0
	for _, card in self.assignedCards:GetAll() do
		pendingEnergyCost += card:GetCost()
	end
	self.pendingEnergyCost = pendingEnergyCost
	return self.pendingEnergyCost
end

--Add a card to be played on their turn.
function SpeedDice:AssignCard(card)
	if self.energy:GetValue() < (self.pendingEnergyCost + card:GetCost()) then warn("Not enough energy.") return end
	
	self.assignedCards:Add(card)
	self:UpdatePendingEnergyCost()
end

--Return the card back to where they came from.
function SpeedDice:UnassignCard(instanceId)
	local card = self.assignedCards:Get(instanceId)
	if not card then return end
	
	self.assignedCards:Remove(instanceId)
	self:UpdatePendingEnergyCost()
	return card
end

--Reduce energy by card cost and move it to be discarded at the end of turn.
function SpeedDice:UseCard()
	local card = self.assignedCards[1]
	self.energy:Use(card:GetCost())
	self.assignedCards:Remove(card:GetInstanceId())
	self.usedCards:Add(card)
	return card
end

function SpeedDice:GetAssignedCards()
	return self.assignedCards
end

function SpeedDice:GetUsedCards()
	return self.usedCards
end

function SpeedDice:GetEnergyValue()
	return self.energy:GetValue()
end

function SpeedDice:Roll()
	self.dice:Roll()
	return self.dice:GetValue()
end

function SpeedDice:GetRollValue()
	return self.dice:GetValue()
end

return SpeedDice