--27/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local IDManager = require(ServerScriptService.Dependencies.IDManager)
local Card = require(ServerScriptService.Card)
local CardTemplates = require(ServerScriptService.CardTemplates)
local CardRegistry = require(ServerScriptService.CardRegistry)

local CardFactory = {}

function CardFactory.Create(templateId)
	local template = CardTemplates[templateId]
	if not template then
		warn("Card template not found: " .. templateId)
		return nil
	end
	
	local card = Card.new(template)
	
	card.instanceId = IDManager.GenerateID()
	
	CardRegistry.Register(card)
	
	return card
end

return CardFactory