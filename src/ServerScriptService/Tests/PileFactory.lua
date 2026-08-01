local Pile = require(game.ServerScriptService.PileFactory) -- adjust path

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		print("✅ " .. name)
	else
		warn("❌ " .. name .. ": " .. tostring(err))
	end
end

-- Helpers
local function makeCard(id)
	return { instanceID = id }
end

-- Constructor
test("Pile.new creates an empty pile", function()
	local p = Pile.new()
	assert(p:Count() == 0, "Expected empty pile")
end)

-- Add + inherited behavior
test("Pile inherits Add / GetAll / Count", function()
	local p = Pile.new()
	p:Add(makeCard(1))
	p:Add(makeCard(2))

	assert(p:Count() == 2, "Expected 2 cards")
	local all = p:GetAll()
	assert(all[1].instanceID == 1 and all[2].instanceID == 2, "Expected correct order")
end)

-- Shuffle
test("Shuffle randomizes order but preserves all items", function()
	local p = Pile.new()
	p:Add(makeCard(1))
	p:Add(makeCard(2))
	p:Add(makeCard(3))
	p:Add(makeCard(4))

	local before = {}
	for _, c in ipairs(p:GetAll()) do
		table.insert(before, c.instanceID)
	end

	p:Shuffle()

	local after = {}
	for _, c in ipairs(p:GetAll()) do
		table.insert(after, c.instanceID)
	end

	-- Same items?
	table.sort(before)
	table.sort(after)
	for i = 1, #before do
		assert(before[i] == after[i], "Shuffle must preserve all items")
	end

	-- Not guaranteed, but usually different order
	-- Only assert that shuffle doesn't break anything
end)

-- Has(instanceID)
test("Has returns true only for matching instanceID", function()
	local p = Pile.new()
	p:Add(makeCard(10))
	p:Add(makeCard(20))

	assert(p:Has(10) == true, "Expected Has(10) true")
	assert(p:Has(20) == true, "Expected Has(20) true")
	assert(p:Has(999) == false, "Expected Has(999) false")
end)

-- Get(instanceID)
test("Get returns the card with matching instanceID", function()
	local p = Pile.new()
	local c1 = makeCard(5)
	local c2 = makeCard(6)
	p:Add(c1)
	p:Add(c2)

	assert(p:Get(5) == c1, "Expected Get(5) to return c1")
	assert(p:Get(6) == c2, "Expected Get(6) to return c2")
	assert(p:Get(999) == nil, "Expected Get(999) nil")
end)

-- Remove(instanceID)
test("Remove removes and returns the correct card", function()
	local p = Pile.new()
	local c1 = makeCard(1)
	local c2 = makeCard(2)
	local c3 = makeCard(3)

	p:Add(c1)
	p:Add(c2)
	p:Add(c3)

	local removed = p:Remove(2)
	assert(removed == c2, "Expected Remove(2) to return c2")
	assert(p:Has(2) == false, "Expected card 2 removed")
	assert(p:Count() == 2, "Expected pile size reduced")
end)

test("Remove returns nil when instanceID not found", function()
	local p = Pile.new()
	p:Add(makeCard(1))

	local removed = p:Remove(999)
	assert(removed == nil, "Expected nil for missing instanceID")
	assert(p:Count() == 1, "Expected count unchanged")
end)

print("Pile tests complete.")

return true