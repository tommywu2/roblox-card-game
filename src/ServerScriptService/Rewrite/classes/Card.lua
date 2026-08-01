--1/08/2026

local Card = {}
Card.__index = Card

function Card.new(template)
    local self = setmetatable({}, Card)

    --[Variables]
    self.name = template.name
    self.description = template.description
    self.cost = template.cost
    self.rarity = template.rarity
    self.moves = template.moves

    self:Reset()

    return self
end

--[Main]
function Card:Reset()
    self.availableMoves = {}
    for _, move in ipairs(self.moves) do
        table.insert(self.availableMoves, move)
    end
end

function Card:UseMove()
    return table.remove(self.availableMoves, 1)
end

--[Getters]
function Card:GetName()
    return self.name
end

function Card:GetDescription()
    return self.description
end

function Card:GetCost()
    return self.cost
end

function Card:GetRarity()
    return self.rarity
end

function Card:GetAvaliableMoves()
    return self.availableMoves
end

--[Setters]
function Card:_SetName(name: string)
    self.name = name
end

function Card:_SetDescription(description: string)
    self.description = description
end

function Card:_SetCost(cost: number)
    self.cost = cost
end

function Card:_SetRarity(rarity: string)
    self.rarity = rarity
end

return Card