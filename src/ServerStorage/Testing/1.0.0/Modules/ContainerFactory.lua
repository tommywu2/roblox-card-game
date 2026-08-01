--9/007/2026

local Container = {}
Container.__index = Container

--[Constructor]
function Container.new()
	local self = setmetatable({}, Container)
	
	self.items = {}
	
	return self
end

--[Logic]
function Container:Add(item)
	table.insert(self.items, item)
end

function Container:Remove(item)
	for i, containerItem in ipairs(self.items) do
		if containerItem == item then
			table.remove(self.items, i)
			return
		end
	end
end

function Container:RemoveAt(index)
	if not self.items[index] then warn("Item not found at index " .. index .. ".") return end
	
	local item = self.items[index]
	table.remove(self.items, index)
	return item
end

function Container:GetAt(index)
	return self.items[index]
end

function Container:GetAll()
	return self.items
end

function Container:Count()
	return #self.items
end

function Container:Contains(item)
	for _, containerItem in ipairs(self.items) do
		if containerItem == item then
			return true
		end
	end
	return false
end

function Container:Clear()
	self.items = {}
end

function Container:ForEach(callback)
	for _, item in ipairs(self.items) do
		callback(item)
	end
end

return Container