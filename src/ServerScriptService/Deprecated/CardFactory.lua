--6/07/2026

local Card = {}
Card.__index = Card

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--[Types]
type Move = typeof(ServerScriptService.MoveFactory)

--[Constructor]
function Card.new(cardID, name, cost, rarity)
	local self = setmetatable({}, Card)
	
	self.cardID = cardID
	self.name = name
	self.cost = cost
	self.rarity = rarity
	
	self.currentMoveIndex = 1
	self.moves = {}
	
	return self
end

--[Logic]
function Card:AddMove(move: Move)
	table.insert(self.moves, move)
end

function Card:Reset()
	self.currentMoveIndex = 1
end

function Card:GetCurrentMove()
	return self.moves[self.currentMoveIndex]
end

function Card:HasMovesLeft()
	return self.currentMoveIndex <= #self.moves
end

function Card:IncrementMoveIndex()
	self.currentMoveIndex += 1
end

--[Helpers]
function Card:GetMoves()
	return self.moves
end

function Card:GetMoveAt(index)
	return self.moves[index]
end

return Card