local Waiting = {}

function Waiting:Enter(stateMachine)
	print("Entering Waiting.")
	
	while not self:AllEntitiesReady(stateMachine:GetEntities()) do
		task.wait(5)
		print("waiting for all entities to be ready")
	end
	
	stateMachine.TransitionTo("Resolution")
end

function Waiting:Exit()
	
end

function Waiting:AllEntitiesReady(entities)
	for _, entity in ipairs(entities) do
		if not entity:IsReady() then
			return false
		end
	end
	return true
end

return Waiting