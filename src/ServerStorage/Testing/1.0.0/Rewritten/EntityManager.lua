--4/07/2026

local EntityManager = {}

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

--[Modules]
local EntityFactory = require(ServerScriptService.EntityFactory)

--[Tables]
local entities = {}

--[Functions]
--Used for creating an entity when a player joins the game and for enemies on the encounter/event.
function EntityManager.CreateEntity(entityID, name, maxHealth, maxEnergy, deck)
	if EntityManager.Has(entityID) then warn("Entity already exists.") return end

	local entity = EntityFactory.new(entityID, name, maxHealth, maxEnergy, deck)

	entities[entityID] = entity

	return entity
end

--[Helpers]
function EntityManager.Has(entityID)
	return entities[entityID] ~= nil
end

function EntityManager.Get(entityID)
	if not entities[entityID] then warn("Entity does not exist.") end
	
	return entities[entityID]
end

return EntityManager