--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local CardFactory = require(ServerScriptService.CardFactory)
local MoveFactory = require(ServerScriptService.MoveFactory)

local TableUtils = require(ServerScriptService.Dependencies.TableUtils)
local IDManager = require(ServerScriptService.Dependencies.IDManager)

local CardLibrary = {}

local blueprints = {
	[1] = {
		name = "Test Attack",
		cost = 1,
		rarity = "Common",
		cardType = "Combat",
		moves = {
			{
				type = "Slash",
				min = 5,
				max = 5,
				
				effects = {
					{
						event = "OnRoll",
						effect = function(owner, ownerMove, opponent, opponentMove)
							print("Triggered Attack effect.")
							ownerMove:SetValue(7)
							opponent:AddStatusEffect(1, 1)
							print("Applied 1 burn to " .. opponent:GetName() .. ".")
						end,
					}
				}
			},
		},
	},
	[2] = {
		name = "Test Block",
		cost = 1,
		rarity = "Common",
		cardType = "Combat",
		moves = {
			{
				type = "Block",
				min = 6,
				max = 6,
				
				effects = {
					{
						event = "OnRoll",
						effect = function(owner, ownerMove, opponent, opponentMove)
							print("Triggered Block effect.")
						end,
					}
				}
			},
		},
	},
	[1000] = {
		name = "Bite Off",
		cost = 1,
		rarity = "Common",
		cardType = "Combat",
		moves = {
			{type = "Slash", min = 1, max = 4},
			{type = "Blunt", min = 1, max = 4},
		},
	},
	[1001] = {
		name = "Backstreets Dash",
		cost = 1,
		rarity = "Common",
		cardType = "Combat",
		moves = {
			{type = "Pierce", min = 1, max = 8},
		},
	},
}

--Returns the data for a card given its ID.
--This is used for getting the properties of a card without creating a new card object and to create new copies.
--This is also used for UI and tooltips.
function CardLibrary.GetBlueprint(cardID)
	return blueprints[cardID]
end

function CardLibrary.CreateCard(cardID)
	local blueprint = blueprints[cardID]
	
	if not blueprint then return end
	
	local card = CardFactory.new(cardID, blueprint.name, blueprint.cost, blueprint.rarity, blueprint.cardType)
	
	for _, moveBlueprint in ipairs(blueprint.moves) do
		local move = MoveFactory.new(moveBlueprint.type, moveBlueprint.min, moveBlueprint.max)
		
		for _, effect in ipairs(moveBlueprint.effects) do
			move:AddEffect(effect.event, effect.effect)
		end
		
		card:AddMove(move)
	end
	
	card.instanceID = IDManager.generateID()
	
	return card
end

return CardLibrary