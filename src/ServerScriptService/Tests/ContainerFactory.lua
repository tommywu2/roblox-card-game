-- Tests/Container.spec.lua
local Container = require(game.ServerScriptService.Dependencies.ContainerFactory) -- adjust path

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		print("✅ " .. name)
	else
		warn("❌ " .. name .. ": " .. tostring(err))
	end
end

-- Add / GetAll
test("Add appends an item", function()
	local c = Container.new()
	c:Add("a")
	c:Add("b")
	local all = c:GetAll()
	assert(#all == 2, "Expected 2 items")
	assert(all[1] == "a" and all[2] == "b", "Expected items in insertion order")
end)

-- GetAt
test("GetAt returns item at index", function()
	local c = Container.new()
	c:Add("x")
	c:Add("y")
	assert(c:GetAt(1) == "x", "Expected 'x' at index 1")
	assert(c:GetAt(2) == "y", "Expected 'y' at index 2")
	assert(c:GetAt(5) == nil, "Expected nil for out-of-range index")
end)

-- Count
test("Count reflects number of items", function()
	local c = Container.new()
	assert(c:Count() == 0, "Expected 0 initially")
	c:Add("a")
	c:Add("b")
	assert(c:Count() == 2, "Expected 2 after adding")
end)

-- Contains
test("Contains finds an item by value", function()
	local c = Container.new()
	local item = {name = "sword"}
	c:Add(item)
	assert(c:Contains(item) == true, "Expected Contains to find the exact item")
	assert(c:Contains({name = "sword"}) == false, "Expected Contains to fail on a different table with same fields")
end)

-- Remove (by value)
test("Remove deletes the matching item", function()
	local c = Container.new()
	local item = {id = 1}
	c:Add(item)
	c:Add({id = 2})
	c:Remove(item)
	assert(c:Count() == 1, "Expected 1 item left")
	assert(c:Contains(item) == false, "Expected removed item to be gone")
end)

test("Remove does nothing if item not found", function()
	local c = Container.new()
	c:Add("a")
	c:Remove("z") -- not present
	assert(c:Count() == 1, "Expected count unchanged when removing non-existent item")
end)

-- RemoveAt
test("RemoveAt removes and returns the item at index", function()
	local c = Container.new()
	c:Add("a")
	c:Add("b")
	c:Add("c")
	local removed = c:RemoveAt(2)
	assert(removed == "b", "Expected removed item to be 'b'")
	assert(c:Count() == 2, "Expected 2 items left")
	assert(c:GetAt(2) == "c", "Expected 'c' to shift into index 2")
end)

test("RemoveAt on invalid index warns and returns nil", function()
	local c = Container.new()
	local removed = c:RemoveAt(1) -- empty container
	assert(removed == nil, "Expected nil when index doesn't exist")
end)

-- Clear
test("Clear empties the container", function()
	local c = Container.new()
	c:Add("a")
	c:Add("b")
	c:Clear()
	assert(c:Count() == 0, "Expected 0 after Clear")
	assert(#c:GetAll() == 0, "Expected GetAll to return empty table after Clear")
end)

-- ForEach
test("ForEach iterates every item in order", function()
	local c = Container.new()
	c:Add(1)
	c:Add(2)
	c:Add(3)

	local seen = {}
	c:ForEach(function(item)
		table.insert(seen, item)
	end)

	assert(#seen == 3, "Expected ForEach to visit 3 items")
	assert(seen[1] == 1 and seen[2] == 2 and seen[3] == 3, "Expected items visited in order")
end)

print("Container tests complete.")

return true