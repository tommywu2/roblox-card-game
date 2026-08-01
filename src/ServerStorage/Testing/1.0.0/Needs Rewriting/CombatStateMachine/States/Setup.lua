local Setup = {}

function Setup:Enter(stateMachine)
	print("Entering Setup.")
	
	stateMachine.GetCombatData():IncrementTurn()
	print("Current turn: " .. stateMachine.GetCombatData():GetCurrentTurn())
	
	for i, entity in ipairs(stateMachine:GetEntities()) do
		entity:GainEnergy()
		entity:DrawCard()
		entity:RollSpeedDice()
	end
	
	print(stateMachine)
	stateMachine.TransitionTo("Waiting")
end

function Setup:Exit()
	
end

return Setup