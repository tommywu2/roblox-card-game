--10/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--[Modules]
local Factory = require(ServerScriptService.StatusEffectFactory)

local StatusEffectLibrary = {}

local blueprints = {
	[1] = {
		name = "Burn",
		description = "Placeholder description",
		
		events = {
			["OnTurnEnd"] = {
				function(self, context)
					context.owner:TakeHit(self:GetStacks())
					LogService:Info(`{context.owner:GetName()} took {self:GetStacks()} damage from {self:GetName()}`)

					self:ChangeStacks(-math.floor(self:GetStacks() * (1 / 3)))
				end,
			}
		}
	},
}

function StatusEffectLibrary.new(statusEffectID, amount)
	local blueprint = blueprints[statusEffectID]

	if not blueprint then return end

	local statusEffect = Factory.new(statusEffectID, blueprint.name, blueprint.description, amount)
	
	for eventName, fns in pairs(blueprint.events) do
		for _, fn in ipairs(fns) do
			statusEffect:AddEvent(eventName, fn)
		end
	end

	return statusEffect
end

return StatusEffectLibrary