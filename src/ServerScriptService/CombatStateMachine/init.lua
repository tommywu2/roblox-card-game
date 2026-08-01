--Services
local ServerScriptService = game:GetService("ServerScriptService")

--Modules
local CombatDataFactory = require(ServerScriptService.CombatDataFactory)
local ClashHandler = require(ServerScriptService.ClashHandler)

local CombatStateMachine = {}

local States = script.States

function CombatStateMachine.TransitionTo(stateName, combat)
	local state = require(States[stateName])
	state:Enter(CombatStateMachine, combat)
end

function CombatStateMachine.StartCombat(entities)
	
	--Logging.
	print("Starting combat.")
	
	CombatStateMachine.entities = entities
	CombatStateMachine.combatData = CombatDataFactory.new(entities)
	
	CombatStateMachine.TransitionTo("Setup")
end

function CombatStateMachine.Reset()
	
end

function CombatStateMachine.GetEntities()
	return CombatStateMachine.entities
end

function CombatStateMachine.GetCombatData()
	return CombatStateMachine.combatData
end

function CombatStateMachine.GetClashHandler()
	return ClashHandler
end

return CombatStateMachine