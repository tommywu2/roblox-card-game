--Services
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

--Folders
local Testing = ServerScriptService.Testing

--Modules
local CombatStateMachine = require(ServerScriptService.CombatStateMachine)

--Testing


local DeckLibrary = require(ServerScriptService.DeckLibrary)
local CardLibrary = require(ServerScriptService.CardLibrary)
local EntityLibrary = require(ServerScriptService.EntityLibrary)
local EntityRegistry = require(ServerScriptService.EntityRegistry)

Players.PlayerAdded:Connect(function(player)
	task.wait(1)
	local playerEntity = EntityRegistry.Get(player.UserId)
	local enemyA = EntityLibrary.CreateEntity(1003)
	
	local playerSpeedDie = playerEntity:GetSpeedDie(1)
	local enemyASpeedDie = enemyA:GetSpeedDie(1)
	
	playerSpeedDie:SetValue(4)
	enemyASpeedDie:SetValue(3)
	
	playerSpeedDie:SetTargetSpeedDie(enemyASpeedDie, playerEntity)
	enemyASpeedDie:SetTargetSpeedDie(playerSpeedDie, enemyA)
	
	playerSpeedDie:ChangeEnergy(5)
	enemyASpeedDie:ChangeEnergy(5)
	
	for i, card in pairs(playerEntity.deck:GetAllCards()) do
		playerEntity:GetHandPile():Add(card)
		print(card)
	end
	
	for i, card in pairs(enemyA.deck:GetAllCards()) do
		enemyA:GetHandPile():Add(card)
		print(card)
	end
	
	playerEntity:DrawCard(1)
	enemyA:DrawCard(1)
	
	print(playerEntity:GetHandPile():GetAt(1))
	print(enemyA:GetHandPile():GetAt(1))
	
	playerEntity:AssignCardToSpeedDie(playerEntity:GetHandPile():GetAt(1), 1)
	--enemyA:AssignCardToSpeedDie(enemyA:GetHandPile():GetAt(1), 1)
	
	enemyA:Ready()
	playerEntity:Ready()
	
	local testCombat = CombatStateMachine.StartCombat({playerEntity, enemyA})
end)