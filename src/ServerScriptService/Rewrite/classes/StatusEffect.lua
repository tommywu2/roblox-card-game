--1/08/2026

local StatusEffect = {}
StatusEffect.__index = StatusEffect

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local GameEvents = require(ServerScriptService.GameEvents)

function StatusEffect.new(template)
    local self = setmetatable({}, StatusEffect)

    self.name = template.name
    self.description = template.description
    self.stacks = template.stacks

    for eventName, fn in pairs(template.events) do
        GameEvents.addListener(eventName, fn)
    end--TODO HERE

    return self
end

--[Main]
function StatusEffect:ChangeStacks(delta: number)
    self.stacks += delta
end

--[Getters]
function StatusEffect:GetName()
    return self.name
end

function StatusEffect:GetDescription()
    return self.description
end

function StatusEffect:GetStacks()
    return self.stacks
end

--[Setters]
function StatusEffect:_SetName(name: string)
    self.name = name
end

function StatusEffect:_SetDescription(description: string)
    self.description = description
end

function StatusEffect:_SetStacks(stacks: number)
    self.stacks = stacks
end

return StatusEffect