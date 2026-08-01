--Services
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--Modules
local SignalManager = require(ServerScriptService.SignalManager)

--Types
type Entity = typeof(ServerScriptService.EntityFactory)
type SpeedDie = typeof(ServerScriptService.SpeedDieFactory)
type Card = typeof(ServerScriptService.CardFactory)
type Move = typeof(ServerScriptService.CardFactory.MoveFactory)

local CombatManager = {}
CombatManager.__index = CombatManager

--Constructor
function CombatManager.new(entities)
	local self = setmetatable({}, CombatManager)
	
	self.entities = entities
	
	self.combatOrder = {}
	
	return self
end

--Extracts the speed dice from the entities and puts them in a table.
function CombatManager:BuildCombatOrder()
	self.combatOrder = {}
	
	for _, entity in pairs(self.entities) do
		local speedDice = entity:GetSpeedDice()
		for _, speedDie in pairs(speedDice) do
			table.insert(self.combatOrder, speedDie)
		end
	end
	LogService:Info('Combat order built.')
end

--Sorts the combat order by speed dice value.
function CombatManager:SortCombatOrder()
	table.sort(self.combatOrder, function(a, b)
		return a:GetValue() > b:GetValue()
	end)
	LogService:Info('Combat order sorted.')
end

function CombatManager:Initialise()
	LogService:Info('Combat manager initialised.')
	self:BuildCombatOrder()
	self:SortCombatOrder()
	
	for _, speedDie in pairs(self.combatOrder) do
		speedDie:ConvertToMoves()
	end
end

function CombatManager:StartTurn()
	for _, speedDie in pairs(self.combatOrder) do
		self:ResolveSpeedDie(speedDie)
	end
end

function CombatManager:GetHighestValidSpeedDie(entity)
	for _, speedDie in pairs(self.combatOrder) do
		if speedDie:GetOwner() == entity and #speedDie:GetMoves() > 0 then
			return speedDie
		end
	end
	return nil
end

--Resolves the clash of one speed die targeting another speed die.
function CombatManager:ResolveSpeedDie(actorSpeedDie: SpeedDie)
	local targetSpeedDie: SpeedDie = actorSpeedDie:GetTarget()
	
	--No target to resolve against, skip this speed die.
	if not targetSpeedDie then return end
	
	--Get the entities that own the speed dice so that damage and effects can be applied later.
	local actor = actorSpeedDie:GetOwner()
	local target = targetSpeedDie:GetOwner()
	
	--Consumes the moves of both entities' speed dice until the attacker has no moves left in this speed die.
	while #actorSpeedDie:GetMoves() > 0 do
		--Only get a move if the entity has a move.
		local actingMove = actorSpeedDie:GetMoves()[1]
		local targetMove = if #targetSpeedDie:GetMoves() > 0 then targetSpeedDie:GetMoves()[1] else nil
		
		--Rolls the values for both moves and then resolves the clash with their values after applying all effects.
		self:ResolveClashMove(actor, target, actingMove, targetMove)
		
		--Only remove if the entity had a move in this clash, empty speed dice shouldn't be touched.
		if actingMove then actorSpeedDie:RemoveMove(1) end
		if targetMove then targetSpeedDie:RemoveMove(1) end
	end
end

--Determines the winner of a clash between two rolls after they had all effects applied to them.
--This is used to determine who takes damage.
local function GetClashWinner(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
	if actorFinalRoll > targetFinalRoll then
		return actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll
	elseif targetFinalRoll > actorFinalRoll then
		return target, actor, targetMove, actorMove, targetFinalRoll, actorFinalRoll
	else
		return nil
	end
end

local function OffensiveClash(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
	local winner: Entity, loser: Entity, winnerMove: Move, loserMove: Move, winnerFinalRoll: number, loserFinalRoll: number = GetClashWinner(actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)

	--Neither entity won, so nothing happens.
	if not winner then return end

	loser:TakeHit(winnerFinalRoll)

	--Triggers the effects of both moves.
	winnerMove:Trigger("OnClashWin")
	loserMove:Trigger("OnClashLose")
	
	LogService:Info(`{winner.name} hits {loser.name} for {winnerFinalRoll} damage.`)
end

local interactions = {
	["Slash"] =  {
		["None"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			target:TakeHit(actorFinalRoll)
			
			actorMove:Trigger("OnClashWin")
			
			LogService:Output(`{actor.name} hits {target.name} for {actorFinalRoll} damage.`)
		end,
		["Slash"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			OffensiveClash(actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)
		end,
		["Pierce"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			OffensiveClash(actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)
		end,
		["Blunt"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			OffensiveClash(actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)
		end,
		["Block"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				target:TakeHit(actorFinalRoll - targetFinalRoll)
				
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")
				
				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")
				targetMove:Trigger("OnDefense")
				
				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				targetMove:Trigger("OnDefense")
				
				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
		["Evade"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				target:TakeHit(actorFinalRoll)
				
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")
				
				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				--TODO: Have move get evade dice to keep itself.
				
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")
				targetMove:Trigger("OnDefense")
				
				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				targetMove:Trigger("OnDefense")
				
				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
	},
	["Pierce"] =  {
		["None"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			target:TakeHit(actorFinalRoll)

			actorMove:Trigger("OnClashWin")

			LogService:Output(`{actor.name} hits {target.name} for {actorFinalRoll} damage.`)
		end,
		["Slash"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			OffensiveClash(actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)
		end,
		["Pierce"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			OffensiveClash(actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)
		end,
		["Blunt"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			OffensiveClash(actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)
		end,
		["Block"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				target:TakeHit(actorFinalRoll - targetFinalRoll)

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
		["Evade"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				target:TakeHit(actorFinalRoll)

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				--TODO: Have move get evade dice to keep itself.

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
	},
	["Blunt"] =  {
		["None"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			target:TakeHit(actorFinalRoll)

			actorMove:Trigger("OnClashWin")

			LogService:Output(`{actor.name} hits {target.name} for {actorFinalRoll} damage.`)
		end,
		["Slash"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			OffensiveClash(actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)
		end,
		["Pierce"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			OffensiveClash(actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)
		end,
		["Blunt"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			OffensiveClash(actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)
		end,
		["Block"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				target:TakeHit(actorFinalRoll - targetFinalRoll)

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
		["Evade"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				target:TakeHit(actorFinalRoll)

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				--TODO: Have move get evade dice to keep itself.

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
	},
	["Block"] =  {
		["None"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played nil {targetFinalRoll}`)
		end,
		["Slash"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")
				actorMove:Trigger("OnDefense")
				
				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				actor:TakeHit(targetFinalRoll - actorFinalRoll)
				
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
		["Pierce"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				actor:TakeHit(targetFinalRoll - actorFinalRoll)

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
		["Blunt"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				target:TakeHit(actorFinalRoll - targetFinalRoll)

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				actorMove:Trigger("OnDefense")
				targetMove:Trigger("OnDefense")
				
				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
		["Block"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
		end,
		["Evade"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")
				actorMove:Trigger("OnDefense")
				
				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				--TODO: Have move get evade dice to keep itself.

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				actorMove:Trigger("OnDefense")
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
	},
	["Evade"] =  {
		["None"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
		end,
		["Slash"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				actor:TakeHit(targetFinalRoll)

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
		["Pierce"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				actor:TakeHit(targetFinalRoll)

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
		["Blunt"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				actor:TakeHit(targetFinalRoll)

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
		["Block"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
		end,
		["Evade"] = function(actor: Entity, target: Entity, actorMove: Move, targetMove: Move, actorFinalRoll: number, targetFinalRoll: number)
			if actorFinalRoll > targetFinalRoll then
				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashWin")
				targetMove:Trigger("OnClashLose")
				actorMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			elseif targetFinalRoll > actorFinalRoll then
				--TODO: Have move get evade dice to keep itself.

				--Triggers the effects of both moves.
				actorMove:Trigger("OnClashLose")
				targetMove:Trigger("OnClashWin")
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			else
				actorMove:Trigger("OnDefense")
				targetMove:Trigger("OnDefense")

				LogService:Info(`Actor: {actor.name} played {actorMove:GetDiceType()} {actorFinalRoll}. Target: {target.name} played {targetMove:GetDiceType()} {targetFinalRoll}`)
			end
		end,
	}
}

--Resolves the clash between the move's of two entities.
function CombatManager:ResolveClashMove(actor, target, actorMove, targetMove)
	--Trigger the effects of both moves.
	if actorMove then actorMove:Trigger("StartOfClash") end
	if targetMove then targetMove:Trigger("StartOfClash") end
	
	--Rolls must happen before effects are applied that modify the result.
	if actorMove then actorMove:Roll() end
	if targetMove then targetMove:Roll() end
	
	--TEMPORARY: Should return the roll after effects have been applied.
	local actorFinalRoll = actorMove:GetValue()
	local targetFinalRoll = if targetMove then targetMove:GetValue() else nil
	
	--Gets the dice type of both moves to decide how they interact with each other.
	local actingMoveDiceType = if actorMove then actorMove:GetDiceType() else "None"
	local targetMoveDiceType = if targetMove then targetMove:GetDiceType() else "None"
	
	LogService:Info(`{actor.name} played {actingMoveDiceType} {actorFinalRoll}. {target.name} played {targetMoveDiceType} {targetFinalRoll}`)
	
	interactions[actingMoveDiceType][targetMoveDiceType](actor, target, actorMove, targetMove, actorFinalRoll, targetFinalRoll)
end

return CombatManager