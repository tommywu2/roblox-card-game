--6/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--[Modules]
local MoveTypeLibrary = require(ServerScriptService.MoveTypeLibrary)

--[Types]
type Entity = typeof(ServerScriptService.EntityFactory)

local Move = {}
Move.__index = Move

--[Constructor]
function Move.new(variant, minValue, maxValue)
	local self = setmetatable({}, Move)
	
	self.variant = MoveTypeLibrary.Get(variant)

	self.minValue = minValue
	self.maxValue = maxValue
	self.value = nil
	
	self.events = {}

	return self
end

--[Clash Resolution]
--
function Move:OnWin(owner, ownerMove, opponent, opponentMove)
	self.variant.OnWin(owner, ownerMove, opponent, opponentMove)
end

function Move:OnLose(owner, ownerMove, opponent, opponentMove)
	self.variant.OnLose(owner, ownerMove, opponent, opponentMove)
end

function Move:OnDraw(owner, ownerMove, opponent, opponentMove)
	self.variant.OnDraw(owner, ownerMove, opponent, opponentMove)
end

--[Logic]
--Use this during the resolution of a move during a clash.
function Move:Roll()
	self.value = math.random(self.minValue, self.maxValue)
end

--Use this to reset the move after the clash is over.
function Move:Reset()
	self.value = nil
end

--[Move Effects]
--Use this to add an effect to an event.
function Move:AddEffect(eventName, effect)
	if not self.events[eventName] then
		self.events[eventName] = {}
	end
	
	table.insert(self.events[eventName], effect)
end

--Use this whenever an event happens so that it can call the effect connected to it.
function Move:FireEvent(eventName, owner, ownerMove, opponent, opponentMove)
	if not self.events[eventName] then return end
	
	for _, fn in ipairs(self.events[eventName]) do
		fn(owner, ownerMove, opponent, opponentMove)
	end
end

--[Helpers]
function Move:GetVariant()
	return self.variant
end

--Use this to determine what the move needs to do in the library during clash resolution.
function Move:GetVariantName()
	return self.variant.name
end

--
function Move:GetVariantCategory()
	return self.variant.category
end

--
function Move:GetValue()
	return self.value
end

function Move:SetValue(value)
	self.value = value
end

return Move