local Move = {}
Move.__index = Move

--Services
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

local Trigger = {
	CombatStart = "CombatStart",
	OnUse = "OnUse",
	StartOfClash = "StartOfClash",
	OnClashWin = "OnClashWin",
	OnClashLose = "OnClashLose",
	OnHit = "OnHit",
	OnDefense = "OnDefense",
}

type CardEffect = typeof(script.Parent.CardEffectFactory)
type Entity = typeof(game.ServerScriptService.EntityFactory)


local CombatDieLibrary = require(ServerScriptService.CombatDieLibrary)


function Move.new(diceType, minValue, maxValue)
	local self = setmetatable({}, Move)
	print(diceType)
	print(CombatDieLibrary.Get(diceType))
	self.diceType = CombatDieLibrary.Get(diceType)
	self.OnWin = self.diceType.OnWin
	self.OnLose = self.diceType.OnLose
	self.OnDraw = self.diceType.OnDraw
	
	
	self.minValue = minValue
	self.maxValue = maxValue
	self.value = nil
	
	self.effects = {}
	
	return self
end

--Rolls the dice before any effects are applied to it.
function Move:Roll()
	self.value = math.random(self.minValue, self.maxValue)
	LogService:Output(`Rolled: {self.value} for {self.diceType} dice.`)
end

function Move:GetValue()
	return self.value
end

function Move:GetDiceType()
	return self.diceType
end

function Move:AddEffect(trigger, cardEffect: CardEffect)
	table.insert(self.effects, {trigger = trigger, cardEffect = cardEffect})
end

function Move:Trigger(trigger, owner: Entity)
	for _, effect in pairs(self.effects) do
		if effect.trigger == trigger then
			effect.effect:Apply(owner)
		end
	end
end

function Move:TestTrigger(trigger1, owner: Entity, move)
	for _, trigger in pairs(self.triggers) do
		if trigger == trigger1 then
			trigger:Apply(owner, move)
		end
	end
end

return Move