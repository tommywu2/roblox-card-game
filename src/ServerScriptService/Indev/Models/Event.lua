--21/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Main]
local Event = {}
Event.__index = Event

function Event.new(data)
	local self = setmetatable({}, Event)

	--self.image = data.image TODO: CONSIDER ADDING
	self.title = data.title
	self.description = data.description

	self.options = {}
	for _, optionData in ipairs(data.options) do
		table.insert(self.options, optionData)
	end

	return self
end

--[Functions]
function Event:GetTitle()
	return self.title
end

function Event:GetDescription()
	return self.description
end

function Event:GetOptions()
	return self.options
end



function Event:SelectOption(optionIndex)
	local option = self.options[optionIndex]

	if not option then return end

	option.OnSelection()
end

return Event
