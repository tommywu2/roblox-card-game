--Services
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--Types
type SpeedDie = typeof(ServerScriptService.SpeedDieFactory)

local ClashHandler = {}

function ClashHandler.ResolveSpeedDice(combatOrder)
	for _, die in ipairs(combatOrder) do
		print("Testing: Resolving " .. die.owner.name .. " die")
		print(die)
		ClashHandler.ResolveSpeedDie(die)
	end
end

function ClashHandler.ResolveSpeedDie(actorDie: SpeedDie)
	local targetDie = actorDie:GetTargetDie()
	
	if not targetDie then return end
	
	local actor = actorDie:GetOwner()
	local target = targetDie:GetOwner()
	
	while actorDie:HasCardsLeft() do
		if targetDie:HasCardsLeft() then
			local actorCard = actorDie:GetCurrentCard()
			local targetCard = targetDie:GetCurrentCard()
			
			ClashHandler.ResolveCard(actor, actorCard, target, targetCard)
		else
			local actorCard = actorDie:GetCurrentCard()
			local targetCard = nil
			
			ClashHandler.ResolveCard(actor, actorCard, target, targetCard)
		end
	end
end

function ClashHandler.ResolveCard(actor, actorCard, target, targetCard)
	if targetCard then
		while actorCard:HasMovesLeft() and targetCard:HasMovesLeft() do
			print("Testing: " .. actor.name .." played " .. actorCard.name)
			print("Testing: " .. target.name .. " played " .. targetCard.name)
			
			local actorMove = actorCard:GetCurrentMove()
			local targetMove = targetCard:GetCurrentMove()
			
			ClashHandler.ResolveMove(actor, actorMove, target, targetMove)
		end
	else
		while actorCard:HasMovesLeft() do
			print("Testing: " .. actor.name .. " played " .. actorCard.name)
			print("Testing: " .. target.name .. " played nil")
			
			local actorMove = actorCard:GetCurrentMove()
			local targetMove = nil
			
			ClashHandler.ResolveMove(actor, actorMove, target, targetMove)
		end
	end
end

function ClashHandler.ResolveMove(actor, actorMove, target, targetMove)
	print("Testing: " .. actor.name .." played " .. actorMove:GetVariantName())
	if targetMove then print("Testing: " .. target.name .." played " .. targetMove:GetVariantName()) end
	
	if actorMove then actorMove:Roll() end
	if targetMove then targetMove:Roll() end
	
	--TEMPORARY: Should return the roll after effects have been applied.
	local actorFinalRoll = actorMove:GetValue()
	local targetFinalRoll = if targetMove then targetMove:GetValue() else 0
	
	--Gets the dice type of both moves to decide how they interact with each other.
	local actingMoveType = if actorMove then actorMove:GetVariantName() else "None"
	local targetMoveType = if targetMove then targetMove:GetVariantName() else "None"
	
	--local actor = actorMove:GetOwner()
	--local target = targetMove:GetOwner()
	
	if actorFinalRoll > targetFinalRoll then
		if targetMove then targetMove:OnLose(target, targetMove, actor, actorMove) end
		print(actorMove)
		print(actorMove:IsCompleted())
		actorMove:OnWin(actor, actorMove, target, targetMove)
	elseif targetFinalRoll > actorFinalRoll then
		actorMove:OnLose(actor, actorMove, target, targetMove)
		if targetMove then targetMove:OnWin(target, targetMove, actor, actorMove) end
	else
		actorMove:OnDraw(actor, actorMove, target, targetMove)
		if targetMove then targetMove:OnDraw(target, targetMove, actor, actorMove) end
	end
end

return ClashHandler