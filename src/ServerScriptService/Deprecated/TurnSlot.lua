--27/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local Dice = require(ServerScriptService.Dice)
local Energy = require(ServerScriptService.Energy)


local TurnSlot = {}
TurnSlot.__index = TurnSlot

function TurnSlot.new()
	local self = setmetatable({}, TurnSlot)
	
	self.available_cards = {}
	self.used_cards = {}
	
	self.dice = Dice.new()
	self.energy = Energy.new()
	
	return self
end

function TurnSlot:AddCard(card)
	table.insert(self.available_cards, card)
end

function TurnSlot:RemoveCard(instanceId)
	for i, card in ipairs(self.available_cards) do
		if card.instanceID == instanceId then
			return table.remove(self.available_cards, i)
		end
	end
end

function TurnSlot:UseCard()
	local card = table.remove(self.available_cards, 1)
	table.insert(self.used_cards, card)
	return card
end

function TurnSlot:GetAvailableCards()
	return self.available_cards
end

function TurnSlot:GetUsedCards()
	return self.used_cards
end

return TurnSlot