--1/08/2026

local Entity = {}
Entity.__index = Entity

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local HealthComponent = require(ServerScriptService.Components.HealthComponent)
local PileFactory = require(ServerScriptService.Factories.PileFactory)


function Entity.new(template)
    local self = setmetatable({}, Entity)

    --[Constants]


    --[Variables]
    self.name = template.name

    self.health = HealthComponent.new(template.health)

    self.piles = {
        hand = PileFactory.new(),
        draw = PileFactory.new(),
        discard = PileFactory.new(),
        banish = PileFactory.new(),
    }


    return self
end

--[Main]
function Entity:TakeDamage()

end


--[Getters]
function Entity:GetName()
    return self.name
end

function Entity:GetHealth()
    return self.health
end


--[Setters]
function Entity:_SetName(name: string)
    self.name = name
end


return Entity