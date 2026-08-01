--25/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local IDManager = require(ServerScriptService.Dependencies.IDManager)
local StatusEffect = require(ServerScriptService.StatusEffect.StatusEffect)
local StatusEffectBlueprints = require(ServerScriptService.StatusEffect.StatusEffectBlueprints)

--[Functions]
function StatusEffectFactory.CreateStatusEffect(blueprintID, stacks)
	local blueprint = StatusEffectBlueprints[blueprintID]

	if not blueprint then return end

	local statusEffect = StatusEffect.new(blueprint.name, blueprint.description, stacks, blueprint.events)

	statusEffect.instanceID = IDManager.generateID()

	return statusEffect
end