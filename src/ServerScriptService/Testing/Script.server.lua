--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--[Modules]
local EntityLibrary = require(ServerScriptService.EntityLibrary)
local CombatData = require(ServerScriptService.CombatDataFactory)
--Isolated entity creation test.
local enemy = EntityLibrary.CreateEntity(1003)
print(enemy.name, enemy.instanceID, enemy.blueprintID)
print(enemy:GetDeck():Count())  -- or however you inspect deck size
print(#enemy:GetSpeedDice())    -- dice count matches blueprint

--Isolated speed die roll and energy test.
LogService:Info("Speed Die Test.")

local die = enemy:GetSpeedDie(1)
die:Roll()
print(die:GetValue())  -- should be within roll.min/max, not nil
print(die:GetEnergy()) -- should start at energy.min

--Combat turn order test.
LogService:Info("Combat Turn Order Test.")

local player = EntityLibrary.CreateEntity(2000)

local combatData = CombatData.new({enemy, player})
enemy:RollSpeedDice()
player:RollSpeedDice()
combatData:CreateTurnOrder()
print(combatData:GetTurnOrder())  -- sorted by roll value, highest first

--Status effect trigger and application test.
LogService:Info("Status Effect Test.")

enemy:AddStatusEffect(1, 3) -- e.g. Burn, 3 stacks
print(enemy:HasStatusEffect(1))
enemy:ProcessStatusEffectEvent("OnTurnEnd", {owner = enemy})
print(enemy:HasStatusEffect(1)) -- stacks reduced or removed depending on Burn's logic

--Card movement test.
LogService:Info("Card Movement Test.")

enemy.drawPile:Clear()
for _, card in ipairs(enemy.deck:GetAllCards()) do
	enemy.drawPile:Add(card)
end
enemy.drawPile:Shuffle()
enemy:DrawCard(5)

enemy:DrawCard(5)
print(enemy:GetHandPile():Count()) -- should be 5 (or less if deck was small)
enemy:MoveAllCards(enemy:GetHandPile(), enemy:GetDiscardPile())
print(enemy:GetHandPile():Count()) -- should be 0
print(enemy:GetDiscardPile():Count()) -- should have the cards

--Assign card and spend energy test.
LogService:Info("Card Assignment Test.")

local card = enemy:GetHandPile():GetAt(1)
enemy:AssignCardToSpeedDie(card, 1)
print(die:GetEnergy()) -- should be reduced by card.cost
die:ChangeEnergy(die.energy.gain) -- simulate turn-start energy gain manually
print(die:GetEnergy())
enemy:AssignCardToSpeedDie(card, 1)
print(die:GetEnergy())
print(die:GetAssignedPile():GetAll())