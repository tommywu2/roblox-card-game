-- Tests/StatusEffectCollection.spec.lua
local StatusEffectCollection = require(game.ServerScriptService.StatusEffectCollection) -- adjust path

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		print("✅ " .. name)
	else
		warn("❌ " .. name .. ": " .. tostring(err))
	end
end

-- Add
test("Add creates a new effect on first add", function()
	local c = StatusEffectCollection.new()
	local instance, status = c:Add(1, 3)
	assert(status == "created", "Expected 'created'")
	assert(instance:GetStacks() == 3, "Expected 3 stacks")
end)

test("Add stacks onto an existing effect", function()
	local c = StatusEffectCollection.new()
	c:Add(1, 3)
	local instance, status = c:Add(1, 2)
	assert(status == "stacked", "Expected 'stacked'")
	assert(instance:GetStacks() == 5, "Expected 5 stacks")
end)

test("Add returns nil for non-positive amounts", function()
	local c = StatusEffectCollection.new()
	local instance, status = c:Add(1, 0)
	assert(instance == nil, "Expected nil instance")
	assert(status == nil, "Expected nil status (Add just does bare 'return')")

	local instance2 = c:Add(1, -5)
	assert(instance2 == nil, "Expected nil for negative amount too")
end)

-- Has / Get
test("Has returns false for missing effect", function()
	local c = StatusEffectCollection.new()
	assert(c:Has(1) == false, "Expected false")
end)

test("Has returns true after adding", function()
	local c = StatusEffectCollection.new()
	c:Add(1, 3)
	assert(c:Has(1) == true, "Expected true")
end)

test("Get returns the stored instance", function()
	local c = StatusEffectCollection.new()
	c:Add(1, 3)
	local instance = c:Get(1)
	assert(instance ~= nil, "Expected an instance")
	assert(instance:GetStacks() == 3, "Expected 3 stacks")
end)

test("Get returns nil for missing effect", function()
	local c = StatusEffectCollection.new()
	assert(c:Get(1) == nil, "Expected nil")
end)

-- Remove
test("Remove deletes the effect", function()
	local c = StatusEffectCollection.new()
	c:Add(1, 3)
	c:Remove(1)
	assert(c:Has(1) == false, "Expected effect removed")
end)

test("Remove on non-existent effect does not error", function()
	local c = StatusEffectCollection.new()
	c:Remove(99) -- should be a harmless no-op
end)

-- ProcessEvent
test("ProcessEvent fires the event on a matching effect", function()
	local c = StatusEffectCollection.new()
	local instance = c:Add(1, 3)

	local fired = false
	instance:AddEvent("OnTurnEnd", function(self, context)
		fired = true
	end)

	c:ProcessEvent("OnTurnEnd", {})
	assert(fired == true, "Expected event to fire")
end)

test("ProcessEvent removes effect if it hits 0 stacks during the event", function()
	local c = StatusEffectCollection.new()
	local instance = c:Add(1, 1)

	instance:AddEvent("OnTurnEnd", function(self, context)
		self:ChangeStacks(-1)
	end)

	c:ProcessEvent("OnTurnEnd", {})
	assert(c:Has(1) == false, "Expected effect removed after trigger reduced stacks to 0")
end)

print("StatusEffectCollection tests complete.")

return true