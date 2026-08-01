--17/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local EventFactory = require(ServerScriptService.Indev.EventFactory)
local CombatEncounterLibrary = require(ServerScriptService.Indev.CombatEncounterLibrary)

--[Main]
local EventLibrary = {}

local blueprints = {
	[2000] = {
		title = "test",
		description = "test description dialog here.",
		options = {
			[1] = {
				text = "option 1",
				OnSelection = function()
					print("option 1 selected")			
				end,
			},
			[2] = {
				text = "option 2",
				OnSelection = function()
					print("option 2 selected")
				end,
			},
			[3] = {
				text = "placeholder text: attack the shopkeeper",
				OnSelection = function()
					print("option 3 selected")
					
					--TELL SERVER TO START COMBAT WITH DEFINED ENEMIES USING ENCOUNTER ID
				end,
			},
			[4] = {
				text = "placeholder text: purchase from the shop",
				OnSelection = function()
					print("option 4 selected")
				end,
			},
		}
	}
}

function EventLibrary.CreateEvent(eventID)
	local blueprint = blueprints[eventID]
	
	if not blueprint then return end
	
	local event = EventFactory.new(blueprint)
	
	return event
end

return EventLibrary
