--27/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]


local Card = {}
Card.__index = Card

function Card.new(template)
	local self = setmetatable({}, Card)
	
	self.id = template.id
	self.name = template.name
	self.cost = template.cost
	self.rarity = template.rarity
	self.moves = template.moves
	
	self.available_moves = {}
	for _, move in ipairs(self.moves) do
		table.insert(self.available_moves, move)
	end
	
	return self
end

function Card:Reset()
	self.available_moves = {}
	for _, move in ipairs(self.moves) do
		table.insert(self.available_moves, move)
	end
end

function Card:UseMove()
	return table.remove(self.available_moves, 1)
end

function Card:GetAvaliableMoves()
	return self.available_moves
end

function Card:GetAvaliableMoveAt(i)
	return self.available_moves[i]
end

function Card:GetAvaliableMovesCount()
	return #self.available_moves
end

function Card:GetMoves()
	return self.moves
end

function Card:GetMoveAt(i)
	return self.moves[i]
end

function Card:GetMovesCount()
	return #self.moves
end

return Card