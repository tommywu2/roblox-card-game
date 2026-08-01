--1/08/2026

local EntityFactory = {}

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local Entity = require(ServerScriptService.Classes.Entity)
local EntityTemplates = require(ServerScriptService.Templates.EntityTemplates)
local EntityRegistry = require(ServerScriptService.Registry.EntityRegistry)

function EntityFactory.create(templateId)
    local template = EntityTemplates[templateId]
    if not template then return end

    local entity = Entity.new(template)

    
end

return EntityFactory