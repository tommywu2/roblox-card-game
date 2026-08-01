--19/07/2026

local EntityRegistry = {}

EntityRegistry.players = {}
EntityRegistry.npcs = {}

function EntityRegistry.AddPlayer(entity)
	EntityRegistry.players[entity.instanceID] = entity
end

function EntityRegistry.RemovePlayer(instanceID)
	EntityRegistry.players[instanceID] = nil
end

function EntityRegistry.GetPlayer(instanceID)
	return EntityRegistry.players[instanceID]
end

function EntityRegistry.GetPlayers()
	return EntityRegistry.players
end

function EntityRegistry.GetPlayerIDs()
	local ids = {}
	
	for id, _ in pairs(EntityRegistry.players) do
		table.insert(ids, id)
	end
	
	return ids
end

function EntityRegistry.AddNPC(entity)
	EntityRegistry.npcs[entity.instanceID] = entity
end

function EntityRegistry.RemoveNPC(instanceID)
	EntityRegistry.npcs[instanceID] = nil
end

function EntityRegistry.GetNPC(instanceID)
	return EntityRegistry.npcs[instanceID]
end

function EntityRegistry.GetNPCs()
	return EntityRegistry.npcs
end

return EntityRegistry