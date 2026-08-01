local EntityLibrary = {}

--Services
local ServerScriptService = game:GetService("ServerScriptService")

--Dependencies
local EntityFactory = require(ServerScriptService.EntityFactory)
local IDManager = require(ServerScriptService.Dependency.IDManager)
local DeckLibrary = require(ServerScriptService.DeckLibrary)
local CardLibrary = require(ServerScriptService.CardFactory.CardLibrary)

local blueprints = {
	[1001] = {
		name = "Player A",
		maxHealth = 10,
		deckBlueprintID = 1001,
		speedDieBlueprintIDs = {1001},
	},
	[1002] = {
		name = "Player B",
		maxHealth = 10,
		deckBlueprintID = 1002,
		speedDieBlueprintIDs = {1001},
	},
	[1003] = {
		name = "Enemy A",
		maxHealth = 10,
		deckBlueprintID = 1003,
		speedDieBlueprintIDs = {1001},
	},
}

function EntityLibrary.CreateEntity(blueprintID, overrides)
	local blueprint = blueprints[blueprintID]
	
	if not blueprint then return end
	
	local entity = EntityFactory.new(blueprint)
	
	entity.instanceID = overrides.instanceID or IDManager.generateID()
	
	entity.blueprintID = blueprintID
	
	return entity
end

return EntityLibrary