local Resolution = {}

function Resolution:Enter(stateMachine)
	print("Entering Resolution.")
	
	stateMachine.GetCombatData():CreateTurnOrder()
	stateMachine.GetClashHandler().ResolveSpeedDice(stateMachine:GetCombatData():GetTurnOrder())
	
	stateMachine.TransitionTo("End")
	
	--Get all entities in combat, get their speed dice and put them in a table sorted.
	--Iterate through each speed die in the table, iterate over each card, have each card resolve their moves.
end

function Resolution:Exit()
	
end

return Resolution