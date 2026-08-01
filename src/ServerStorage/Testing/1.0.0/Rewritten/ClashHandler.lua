--9/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--[Types]
type SpeedDie = typeof(ServerScriptService.SpeedDieFactory)

local ClashHandler = {}

function ClashHandler.ResolveSpeedDice(combatOrder)
	for _, die in ipairs(combatOrder) do
		--Logging.
		print("Testing: Resolving " .. die.owner.name .. " die")
		
		ClashHandler.ResolveSpeedDie(die)
	end
end

function ClashHandler.ResolveSpeedDie(actorDie: SpeedDie)
	local targetDie = actorDie:GetTargetDie()
	
	if not targetDie then return end
	
	local actor = actorDie:GetOwner()
	local target = targetDie:GetOwner()
	
	while actorDie:GetAssigned():Count() > 0 do
		if targetDie:GetAssigned():Count() > 0 then
			local actorCard = actorDie:GetAssigned():GetAt(1)
			local targetCard = targetDie:GetAssigned():GetAt(1)
			
			ClashHandler.ResolveCard(actor, actorCard, target, targetCard)
			
			if not actorCard:HasMovesLeft() then actorDie:ArchiveCard(actorCard) end
			if not targetCard:HasMovesLeft() then targetDie:ArchiveCard(targetCard) end
		else
			local actorCard = actorDie:GetAssigned():GetAt(1)
			local targetCard = nil
			
			ClashHandler.ResolveCard(actor, actorCard, target, targetCard)
			
			if not actorCard:HasMovesLeft() then actorDie:ArchiveCard(actorCard) end
		end
	end
end

function ClashHandler.ResolveCard(actor, actorCard, target, targetCard)
	if targetCard then
		while actorCard:HasMovesLeft() and targetCard:HasMovesLeft() do
			--Logging.
			print("Testing: " .. actor.name .." played " .. actorCard.name)
			print("Testing: " .. target.name .. " played " .. targetCard.name)

			local actorMove = actorCard:GetCurrentMove()
			local targetMove = targetCard:GetCurrentMove()

			ClashHandler.ResolveMove(actor, actorMove, target, targetMove)
			actorCard:IncrementMoveIndex()
			targetCard:IncrementMoveIndex()
		end
	else
		while actorCard:HasMovesLeft() do
			--Logging.
			print("Testing: " .. actor.name .. " played " .. actorCard.name)
			print("Testing: " .. target.name .. " played nil")

			local actorMove = actorCard:GetCurrentMove()
			local targetMove = nil

			ClashHandler.ResolveMove(actor, actorMove, target, targetMove)
			actorCard:IncrementMoveIndex()
		end
	end
end

function ClashHandler.ResolveMove(actor, actorMove, target, targetMove)
	--Logging.
	print("Testing: " .. actor.name .." played " .. actorMove:GetVariantName())
	if targetMove then print("Testing: " .. target.name .." played " .. targetMove:GetVariantName()) end

	--Move rolling.
	if actorMove then actorMove:Roll() end
	if targetMove then targetMove:Roll() end

	--TODO TEMPORARY: Should return the roll after effects have been applied.
	local actorFinalRoll = actorMove:GetValue()
	local targetFinalRoll = if targetMove then targetMove:GetValue() else 0

	if actorFinalRoll > targetFinalRoll then
		if targetMove then targetMove:OnLose(target, targetMove, actor, actorMove) end
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