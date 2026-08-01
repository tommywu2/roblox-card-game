--12/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local DeckFactory = require(ServerScriptService.DeckFactory)
local CardLibrary = require(ServerScriptService.CardLibrary)

local DeckLibrary = {}

local blueprints = {
	[1001] = {
		cards = {2, 2, 2, 2, 2, 2}
	},
	[1002] = {
		cards = {1, 1, 1, 1, 1, 1}
	},
	[1003] = {
		cards = {2, 2, 2, 2, 2, 2}
	},
	[2000] = {
		cards = {1, 1, 1, 1, 1, 1}
	}
}

--[Logic]
function DeckLibrary.CreateDeck(deckID)
	local blueprint = blueprints[deckID]

	if not blueprint then return end

	local deck = DeckFactory.new()

	for _, cardID in ipairs(blueprint.cards) do
		deck:Add(CardLibrary.CreateCard(cardID))
	end
	
	return deck
end

return DeckLibrary