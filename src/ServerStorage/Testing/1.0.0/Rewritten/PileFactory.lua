--10/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local ContainerFactory = require(ServerScriptService.ContainerFactory)

local Pile = {}
Pile.__index = Pile

--[Constructor]
function Pile.new()
	local self = setmetatable(ContainerFactory.new(), Pile)
	
	return self
end

--[Logic]
function Pile:Shuffle() 
	for i = self:Count(), 2, -1 do
		local j = math.random(1, i)
		self.items[i], self.items[j] = self.items[j], self.items[i]
	end
end

function Pile:Remove(instanceID)
	for i, card in ipairs(self.items) do
		if card.instanceID == instanceID then
			table.remove(self.items, i)
			return card
		end
	end
end

function Pile:Has(instanceID)
	for _, card in ipairs(self.items) do
		if card.instanceID == instanceID then
			return true
		end
	end
	return false
end

function Pile:Get(instanceID)
	for _, card in ipairs(self.items) do
		if card.instanceID == instanceID then
			return card
		end
	end
end

return Pile