--12/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--[Modules]
local PileFactory = require(ServerScriptService.PileFactory)
local DeckLibrary = require(ServerScriptService.DeckLibrary)
local SpeedDieCollection = require(ServerScriptService.SpeedDieCollection)
local StatusEffectCollection = require(ServerScriptService.StatusEffectCollection)



--TEMPORARY
local SpeedDieFactory = require(ServerScriptService.SpeedDieFactory)

--[Types]
type Pile = typeof(PileFactory.new())


local Entity = {}
Entity.__index = Entity

--Types
type Entity = typeof(Entity)
type Card = typeof(ServerScriptService.CardFactory)

type SpeedDie = typeof(ServerScriptService.SpeedDieFactory)
type SpeedDiceCallback = ({SpeedDie}) -> ()

--Constructor
function Entity.new(blueprint: {})
	local self = setmetatable({}, Entity)
	
	self.name = blueprint.name
	self.health = blueprint.maxHealth
	self.maxHealth = blueprint.maxHealth
	
	self.deck = DeckLibrary.CreateDeck(blueprint.deckBlueprintID)
	
	self.drawPile = PileFactory.new()
	self.handPile = PileFactory.new()
	self.discardPile = PileFactory.new()
	self.banishPile = PileFactory.new()
	
	self.statusEffects = StatusEffectCollection.new(self)
	
	--List of speed dice objects.
	self.speedDice = SpeedDieCollection.new(self)
	self.speedDice:LoadFromLibrary(blueprint.speedDieBlueprintIDs)
	
	--[Constants]
	self.BASE_DRAW_AMOUNT = 5
	self.MAX_HAND_SIZE = 10
	
	return self
end

--[Entity]
function Entity:TakeDamage(damage)
	self.health = math.max(self.health - damage, 0)
end

function Entity:TakeHit(damage)
	--TODO: Apply status effects.
	local finalDamage = damage
	
	self:TakeDamage(finalDamage)
end

function Entity:Heal(amount)
	self.health = math.min(self.health + amount, self.maxHealth)
end

function Entity:IsDead()
	return self.health <= 0
end

--[Speed Die]
function Entity:ResetSpeedDice()
	self.speedDice:ForEach(function(speedDie)
		speedDie:GetArchivedPile():ForEach(function(card)
			self:GetDiscardPile():Add(card)
		end)
		speedDie:GetArchivedPile():ForEach(function(card)
			self:GetDiscardPile():Add(card)
		end)
		speedDie:Reset()
	end)
end

function Entity:GetSpeedDie(index: number)
	return self.speedDice:GetAt(index)
end

function Entity:GetSpeedDice()
	return self.speedDice:GetAll()
end

function Entity:RollSpeedDice()
	self.speedDice:RollAll()
end

function Entity:LockSpeedDice()
	self.speedDice:LockAll()
end

function Entity:UnlockSpeedDice()
	self.speedDice:UnlockAll()
end

--[Card Assignment]
function Entity:AssignCardToSpeedDie(card: Card, index: number)
	local speedDie = self:GetSpeedDie(index)
	if not speedDie then return end
	
	self.handPile:Remove(card)
	speedDie:AssignCard(card)
end

function Entity:UnassignCardFromSpeedDie(card: Card, index: number)
	local speedDie = self:GetSpeedDie(index)
	if not speedDie then return end
	
	speedDie:UnassignCard(card)
	self.handPile:Add(card)
end

--[Targeting]
function Entity:SetSpeedDieTarget(index: number, target: SpeedDie)
	local speedDie = self:GetSpeedDie(index)
	if not speedDie then return end
	
	speedDie:SetTargetSpeedDie(target)
end

function Entity:ClearSpeedDieTarget(index: number)
	local speedDie = self:GetSpeedDie(index)
	if not speedDie then return end
	
	speedDie:ClearTargetSpeedDie()
end

--[Status Effects]
function Entity:AddStatusEffect(statusEffectID: number, stacks: number)
	self.statusEffects:Add(statusEffectID, stacks)
end

function Entity:RemoveStatusEffect(statusEffectID: number)
	self.statusEffects:Remove(statusEffectID)
end

function Entity:HasStatusEffect(statusEffectID: number)
	return self.statusEffects:Has(statusEffectID)
end

function Entity:ProcessStatusEffectEvent(eventName: string, context)
	self.statusEffects:ProcessEvent(eventName, context)
end

--[Deck]
function Entity:AddCardToDeck(card: Card)
	self.deck:Add(card)
end

function Entity:RemoveCardFromDeck(instanceID)
	self.deck:Remove(instanceID)
end

--[Card Piles]
function Entity:MoveCard(instanceID, fromPile: Pile, toPile: Pile)
	if fromPile:Has(instanceID) then
		local card = fromPile:Remove(instanceID)
		toPile:Add(card)
	end
end

function Entity:MoveAllCards(fromPile: Pile, toPile: Pile)
	for _, card in ipairs(fromPile:GetAll()) do
		toPile:Add(card)
		fromPile:Remove(card.instanceID)
	end
end

--[Player Actions]
function Entity:DrawCard(amount)
	if amount == nil then amount = self.BASE_DRAW_AMOUNT end

	for i = 1, amount do
		if self.drawPile:Count() == 0 then
			self.discardPile:Shuffle()

			while self.discardPile:Count() > 0 do
				local card = self.discardPile:RemoveAt(1)
				self.drawPile:Add(card)
			end
		end

		if self.drawPile:Count() > 0 then
			local card = self.drawPile:RemoveAt(1)
			self.handPile:Add(card)
		end
	end
end

function Entity:Ready()
	self:LockSpeedDice()
	self.isReady = true
end

function Entity:Unready()
	self:UnlockSpeedDice()
	self.isReady = false
end

function Entity:IsReady()
	return self.isReady
end

--[Helpers]
--Should be read only.
function Entity:GetName()
	return self.name
end

--Should be read only.
function Entity:GetHealth()
	return self.health
end

--Should be read only.
function Entity:GetMaxHealth()
	return self.maxHealth
end

--Should be read only.
function Entity:GetDeck()
	return self.deck
end

function Entity:GetDrawPile()
	return self.drawPile
end

function Entity:GetHandPile()
	return self.handPile
end

function Entity:GetDiscardPile()
	return self.discardPile
end

function Entity:GetBanishPile()
	return self.banishPile
end

function Entity:GetStatusEffects()
	return self.statusEffects:GetAll()
end

return Entity