--21/07/2026

local EntityBlueprints = {
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

return EntityBlueprints