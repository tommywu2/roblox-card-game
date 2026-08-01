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

function CombatManager:CreateCombatOrder()
	for _, entity in pairs(self.entities) do
		local speedDice = entity:GetSpeedDice()
		for _, speedDie in pairs(speedDice) do
			table.insert(self.combatOrder, speedDie)
		end
	end
	LogService:Info('Combat order built.')
	
	table.sort(self.combatOrder, function(a, b)
		return a:GetValue() > b:GetValue()
	end)
	LogService:Info('Combat order sorted.')
	print(self.combatOrder)
end

function CombatManager:StartTurn()
	for _, entity in pairs(self.entities) do
		entity:StartTurn()
	end
end

function CombatManager:EndTurn()
	LogService:Info("Ending turn.")
	
	for _, entity in pairs(self.entities) do
		entity:EndTurn()
	end
	
	for _, entity in pairs(self.entities) do
		entity:FireEvent("OnTurnEnd")
	end
	
	for _, entity in pairs(self.entities) do
		print(`{entity:GetName()} health: {entity:GetHealth()}`)
	end
	task.wait(5)
	self:StartTurn()
end

function CombatManager:Reset()
	for _, entity in pairs(self.entities) do
		entity:Reset()
	end
end

function CombatManager:ConvertToMoves()
	for _, die in pairs(self.combatOrder) do
		die:ConvertToMoves()
	end
end

function CombatManager:ResolveSpeedDice()
	for _, die in ipairs(self.combatOrder) do
		print(die)
		self:ResolveSpeedDie(die)
	end
end

--Resolves the clash of one speed die targeting another speed die.
function CombatManager:ResolveSpeedDie(actorSpeedDie: SpeedDie) LogService:Info("Called CombatManager:ResolveSpeedDie")
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

--Resolves the clash between the move's of two entities.
function CombatManager:ResolveClashMove(actor, target, actorMove, targetMove) LogService:Info("Called CombatManager:ResolveClashMove")
	--Trigger the effects of both moves.
	if actorMove then actorMove:FireEvent("StartOfClash", actor, actorMove, target, targetMove) end
	if targetMove then targetMove:FireEvent("StartOfClash", target, targetMove, actor, actorMove) end
	
	--Rolls must happen before effects are applied that modify the result.
	if actorMove then actorMove:Roll() LogService:Output(`{actor.name} rolled {actorMove:GetValue()} for {actorMove:GetVariantName()}`) end
	if targetMove then targetMove:Roll() LogService:Output(`{target.name} rolled {targetMove:GetValue()} for {targetMove:GetVariantName()}`) end
	
	if actorMove then actorMove:FireEvent("OnRoll", actor, actorMove, target, targetMove) end
	if targetMove then targetMove:FireEvent("OnRoll", target, targetMove, actor, actorMove) end
	
	--TEMPORARY: Should return the roll after effects have been applied.
	local actorFinalRoll = actorMove:GetValue()
	local targetFinalRoll = if targetMove then targetMove:GetValue() else 0
	
	--Gets the dice type of both moves to decide how they interact with each other.
	local actingMoveType = if actorMove then actorMove:GetVariantName() else "None"
	local targetMoveType = if targetMove then targetMove:GetVariantName() else "None"
	
	LogService:Info(`{actor.name} played {actingMoveType} {actorFinalRoll}. {target.name} played {targetMoveType} {targetFinalRoll}`)
	
	if actorFinalRoll > targetFinalRoll then
		if targetMove then targetMove.OnLose(target, targetMove, actor, actorMove) end
		actorMove.OnWin(actor, actorMove, target, targetMove)
		
		if actorMove then actorMove:FireEvent("OnClashWin", actor, actorMove, target, targetMove) end
		if targetMove then targetMove:FireEvent("OnClashLose", target, targetMove, actor, actorMove) end
	elseif targetFinalRoll > actorFinalRoll then
		actorMove.OnLose(actor, actorMove, target, targetMove)
		if targetMove then targetMove.OnWin(target, targetMove, actor, actorMove) end
		
		if actorMove then actorMove:FireEvent("OnClashLose", actor, actorMove, target, targetMove) end
		if targetMove then targetMove:FireEvent("OnClashWin", target, targetMove, actor, actorMove) end
	else
		actorMove.OnDraw(actor, actorMove, target, targetMove)
		if targetMove then targetMove.OnDraw(target, targetMove, actor, actorMove) end
	end
end

--HELPER FUNCTIONS

function CombatManager:GainEnergy(amount)
	for _, entity in pairs(self.entities) do
		entity:GainEnergy(amount)
	end
end

function CombatManager:DrawCards(amount)
	for _, entity in pairs(self.entities) do
		entity:DrawCard(amount)
	end
end

function CombatManager:RollSpeedDice()
	for _, entity in pairs(self.entities) do
		entity:RollSpeedDice()
	end
end

function CombatManager:AllEntitiesReady()
	for _, entity in ipairs(self.entities) do
		if not entity:IsReady() then
			return false
		end
	end
	return true
end

return CombatManager