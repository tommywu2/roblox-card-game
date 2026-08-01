
--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local CombatStateMachine = require(ServerScriptService.CombatStateMachine)
local EntityRegistry = require(ServerScriptService.Indev.EntityRegistry)

local CombatEncounter = {}
CombatEncounter.__index = CombatEncounter

--[Constructor]
function CombatEncounter.new(data)
	local self = setmetatable({}, CombatEncounter)
	
	self.enemies = data.enemies
	
	return self
end

function CombatEncounter:Start()
	print("combat started")
	
	local allEntities = {}
	
	for _, player in pairs(EntityRegistry:GetPlayers()) do
		table.insert(allEntities, player)
	end
	
	for _, enemy in pairs(self.enemies) do
		table.insert(allEntities, enemy)
	end
	
	print(allEntities)
	CombatStateMachine.StartCombat(allEntities)
end

return CombatEncounter