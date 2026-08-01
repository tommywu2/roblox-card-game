--Services
local ServerScriptService = game:GetService("ServerScriptService")

--Modules
local EntityManager = require(ServerScriptService.Testing.EntityManager2)
local EntityLibrary = require(ServerScriptService.EntityFactory.EntityLibrary)
local CombatStateMachine = require(ServerScriptService.CombatStateMachine)

--Testing
wait(1)
local playerEntities = EntityManager.GetPlayers()
local enemyA = EntityLibrary.CreateEntity(1003)
local enemyEntities = {enemyA}

print(playerEntities)
print(enemyEntities)

local allEntities = {}
local playerSpeedDie
for _, playerEntity in pairs(playerEntities) do
	table.insert(allEntities, playerEntity)
	playerSpeedDie = playerEntity:GetSpeedDie(1)
end
for _, enemyEntity in pairs(enemyEntities) do
	table.insert(allEntities, enemyEntity)
	enemyEntity:AddCardToSpeedDie(1, enemyEntity.deck:GetAt(1), enemyEntity.deck)
	enemySpeedDie = enemyEntity:GetSpeedDie(1)
	enemySpeedDie:SetTarget(playerSpeedDie, enemyEntity)
end

print(allEntities)

for _, entity in pairs(allEntities) do
	print(entity)
	entity:RollSpeedDice()
	entity:Ready()
end

CombatStateMachine.StartCombat(allEntities)