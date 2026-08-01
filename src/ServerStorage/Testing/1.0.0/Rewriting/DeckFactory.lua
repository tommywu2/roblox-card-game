--Dependencies
local TableUtils = require(game.ServerScriptService.Dependency.TableUtils)

local Deck = {}
Deck.__index = Deck

function Deck.new()
	local self = setmetatable({}, Deck)
	
	self.cards = {}
	
	return self
end

--Shuffles the deck using the Fisher-Yates shuffle.
--Intended for use before combat.
function Deck:Shuffle() 
	for i = #self.cards, 2, -1 do
		local j = math.random(1, i)
		self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
	end
end

--Adds a real card object to the deck.
--The card must have an instanceID property.
--CardLibrary should be used to create cards and is responsible for generating instanceIDs.
function Deck:Add(card)
	table.insert(self.cards, card)
end

--Removes a real card object from the deck.
--Returns the exact copy of the card.
function Deck:Remove(instanceID)
	for i, card in ipairs(self.cards) do
		if card.instanceID == instanceID then
			table.remove(self.cards, i)
			return card
		end
	end
end

--
function Deck:RemoveAt(index)
	if not self.cards[index] then warn("Card not found at index " .. index .. ".") return end
	
	local card = self.cards[index]
	
	table.remove(self.cards, index)

	return card
end

--Returns a copy of the card.
--Does not remove the card.
--Does not modify the deck.
--This is so the caller cannot mutate the card.
--The copy should be used for checking if a card is in the deck.
function Deck:Get(instanceID)
	for _, card in ipairs(self.cards) do
		if card.instanceID == instanceID then
			local copy = TableUtils.copy(card, true)
			
			return copy
		end
	end
end

--Returns a copy of the card at the given index.
--Intended for inspection and certain effects.
--Use this when you need to check the card without modifying it.
function Deck:GetAt(index)
	if not self.cards[index] then warn("Card not found at index " .. index .. ".") return end
	
	local copy = TableUtils.copy(self.cards[index], true)
	
	return copy
end

--Returns a copy of the deck.
--Intended for inspection and copying.
--Use this when you need to check the deck without modifying it.
function Deck:GetAllCards()
	local copy = TableUtils.copy(self.cards, true)
	
	return copy
end

--Sets the deck to a given set of cards by deep copying the cards.
--This is used mainly to create a copy of the player's deck to their draw pile before combat.
--This is because the player's cards can be mutated by effects during combat and we need to preserve the original deck.
function Deck:Set(cards)
	local copy = TableUtils.copy(cards, true)
	
	self.cards = copy
end

--Removes all cards from the deck.
--This is mainly used to clear the player's deck after combat except for their original deck.
function Deck:Clear()
	self.cards = {}
end

--Returns the number of cards in the deck.
--This is used to check if the deck is empty.
--This is also used to check if the hand is full and if they can draw a card.
--This can be used for effects like "If you have 5 cards in your hand, you can do X" or "You can only play 3 cards from your hand".
function Deck:Count()
	return #self.cards
end

return Deck