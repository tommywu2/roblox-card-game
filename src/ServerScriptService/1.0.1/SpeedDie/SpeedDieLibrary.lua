--12/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--[Modules]
local Factory = require(ServerScriptService.SpeedDieFactory)

local SpeedDieLibrary = {}

local blueprints = {
	[1001] = {
		roll = {
			min = 1,
			max = 6,
		},
		energy = {
			min = 0,
			max = 6,
			gain = 1,
		},
	},
}

function SpeedDieLibrary.CreateSpeedDie(owner, blueprintID)
	local blueprint = blueprints[blueprintID]

	if not blueprint then return end
	
	local speedDie = Factory.new(owner, blueprint)
	
	return speedDie
end

return SpeedDieLibrary