--21/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local Entity = require(ServerScriptService.Indev.Entity)
local EntityBlueprints = require(ServerScriptService.Indev.EntityBlueprints)
local EntityRegistry = require(ServerScriptService.Indev.EntityRegistry)
local IDManager = require(ServerScriptService.Dependencies.IDManager)

local EntityFactory = {}

function EntityLibrary.CreatePlayerEntity(blueprintID, playerID)
	local blueprint = EntityBlueprints[blueprintID]

	if not blueprint then return end

	local entity = Entity.new(blueprint)

	entity.instanceID = playerID

	entity.blueprintID = blueprintID

	EntityRegistry.AddPlayer(entity)

	return entity
end

function EntityLibrary.CreateNPCEntity(blueprintID)
	local blueprint = EntityBlueprints[blueprintID]

	if not blueprint then return end

	local entity = Entity.new(blueprint)

	entity.instanceID = IDManager.generateID()

	entity.blueprintID = blueprintID

	EntityRegistry.AddNPC(entity)

	return entity
end

return EntityFactory