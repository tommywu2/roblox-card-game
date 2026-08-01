--20/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local IDManager = require(ServerScriptService.Dependencies.IDManager)
local EntityRegistry = require(ServerScriptService.Indev.EntityRegistry)
local EntityFactory = require(ServerScriptService.Indev.EntityFactory)

--[Main]
local EntityLibrary = {}

--[Blueprints]
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
	[2000] = {
		name = "Testing Player",
		maxHealth = 10,
		deckBlueprintID = 2000,
		speedDieBlueprintIDs = {1001},
	},
}

--[Functions]


return EntityLibrary