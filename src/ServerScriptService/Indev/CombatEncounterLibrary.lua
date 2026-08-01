

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local CombatEncounterFactory = require(ServerScriptService.Indev.CombatEncounterFactory)
local EntityLibrary = require(ServerScriptService.Indev.EntityLibrary)

--[Main]
local CombatEncounterLibrary = {}

local blueprints = {
	[2000] = {
		enemiesID = {1003},
		enemies = {},
	}
}

function CombatEncounterLibrary.CreateEncounter(encounterID)
	local blueprint = blueprints[encounterID]

	if not blueprint then return end
	
	for _, enemyID in pairs(blueprint.enemiesID) do
		local enemy = EntityLibrary.CreateEntity(enemyID)
		table.insert(blueprint.enemies, enemy)
	end
	
	local encounter = CombatEncounterFactory.new(blueprint)

	return encounter
end

return CombatEncounterLibrary
