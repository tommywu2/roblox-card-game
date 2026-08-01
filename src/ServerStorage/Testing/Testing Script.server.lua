local CombatManager = require(game.ServerScriptService.CombatManagerExperimental)
local EntityFactory = require(game.ServerScriptService.EntityFactory)
local DeckFactory = require(game.ServerScriptService.DeckFactory)
local CardLibrary = require(game.ServerScriptService.CardFactory.CardLibrary)
local EntityLibrary = require(game.ServerScriptService.EntityFactory.EntityLibrary)

local testDeck1 = DeckFactory.new()
testDeck1:Add(CardLibrary.CreateCard(2))

local testDeck2 = DeckFactory.new()
testDeck2:Add(CardLibrary.CreateCard(1))

local testDeck3 = DeckFactory.new()
testDeck3:Add(CardLibrary.CreateCard(1))

local playerA = EntityLibrary.CreateEntity(1001)
local playerB = EntityLibrary.CreateEntity(1002)
local enemyA = EntityLibrary.CreateEntity(1003)

local testCombat = CombatManager.new({playerA, playerB, enemyA})

local playerASpeedDie = playerA:GetSpeedDie(1)
local playerBSpeedDie = playerB:GetSpeedDie(1)
local enemyASpeedDie = enemyA:GetSpeedDie(1)

playerASpeedDie:SetTarget(enemyASpeedDie, playerA)
playerBSpeedDie:SetTarget(enemyASpeedDie, playerB)
enemyASpeedDie:SetTarget(playerASpeedDie, enemyA)

playerA:AddCardToSpeedDie(1, playerA.deck:GetAt(1), playerA.deck)
playerB:AddCardToSpeedDie(1, playerB.deck:GetAt(1), playerB.deck)
enemyA:AddCardToSpeedDie(1, enemyA.deck:GetAt(1), enemyA.deck)

playerASpeedDie:SetValue(2)
playerBSpeedDie:SetValue(1)
enemyASpeedDie:SetValue(3)

testCombat:Initialise()

playerA:Ready()
playerB:Ready()
enemyA:Ready()

testCombat:StartTurn()


print("PlayerA health: " .. playerA.health)
print("PlayerB health: " .. playerB.health)
print("EnemyA health: " .. enemyA.health)