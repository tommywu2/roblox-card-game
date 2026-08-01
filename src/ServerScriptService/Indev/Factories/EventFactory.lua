--21/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local Event = require(ServerScriptService.Indev.Models.Event)
local EventBlueprints = require(ServerScriptService.Indev.Blueprints.EventBlueprints)

local EventFactory = {}

function EventFactory.CreateEvent(eventID)
	local blueprint = EventBlueprints[eventID]
	print(eventID)
	if not blueprint then return end

	local event = Event.new(blueprint)

	return event
end

return EventFactory