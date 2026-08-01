--20/07/2026

--[Main]
local Node = {}
Node.__index = Node

--[Constructor]
function Node.new(data)
	local self = setmetatable({}, Node)
	
	self.title = data.title
	
	self.eventIDs = data.eventIDs
	
	return self
end

--[Functions]
function Node:SelectEvent(index)
	return self.eventIDs[index]
end

return Node