local End = {}

function End:Enter(stateMachine)
	print("Entering End.")
	
	for i, entity in ipairs(stateMachine:GetEntities()) do
		entity:MoveAllCards(entity:GetDiscardPile(), entity:GetHandPile())
		entity:ResetSpeedDice()
		print(entity)
	end
	
	task.wait(10)
	stateMachine.TransitionTo("Setup")
end

function End:Exit()
	
end

return End