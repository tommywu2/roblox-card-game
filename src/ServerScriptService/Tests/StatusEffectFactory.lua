-- Tests/StatusEffect.spec.lua
local StatusEffect = require(game.ServerScriptService.StatusEffectFactory)

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		print("✅ " .. name)
	else
		warn("❌ " .. name .. ": " .. tostring(err))
	end
end

-- Constructor
test("new creates a status effect with correct fields", function()
	local se = StatusEffect.new(10, "Burn", "Deals damage over time", 3)

	assert(se:GetID() == 10, "Expected ID = 10")
	assert(se:GetName() == "Burn", "Expected name = Burn")
	assert(se:GetDescription() == "Deals damage over time", "Expected description")
	assert(se:GetStacks() == 3, "Expected stacks = 3")
end)

-- ChangeStacks
test("ChangeStacks increases stacks", function()
	local se = StatusEffect.new(1, "Burn", nil, 2)
	se:ChangeStacks(5)
	assert(se:GetStacks() == 7, "Expected stacks = 7")
end)

test("ChangeStacks clamps stacks to zero", function()
	local se = StatusEffect.new(1, "Burn", nil, 2)
	se:ChangeStacks(-10)
	assert(se:GetStacks() == 0, "Expected stacks = 0")
end)

-- SetStacks
test("SetStacks sets stacks and clamps to zero", function()
	local se = StatusEffect.new(1, "Burn", nil, 5)
	se:SetStacks(-3)
	assert(se:GetStacks() == 0, "Expected stacks = 0")
end)

-- AddEvent
test("AddEvent registers callbacks under event name", function()
	local se = StatusEffect.new(1, "Burn", nil, 1)

	se:AddEvent("OnApply", function() end)
	se:AddEvent("OnApply", function() end)

	assert(#se.events["OnApply"] == 2, "Expected 2 callbacks registered")
end)

-- FireEvent
test("FireEvent calls all callbacks", function()
	local se = StatusEffect.new(1, "Burn", nil, 1)

	local a = false
	local b = false

	se:AddEvent("OnApply", function() a = true end)
	se:AddEvent("OnApply", function() b = true end)

	se:FireEvent("OnApply")

	assert(a == true, "Expected first callback to fire")
	assert(b == true, "Expected second callback to fire")
end)

test("FireEvent passes self and context", function()
	local se = StatusEffect.new(1, "Burn", nil, 1)

	local gotSelf, gotContext

	se:AddEvent("OnTick", function(selfObj, ctx)
		gotSelf = selfObj
		gotContext = ctx
	end)

	local ctx = { damage = 12 }
	se:FireEvent("OnTick", ctx)

	assert(gotSelf == se, "Expected self to be passed")
	assert(gotContext.damage == 12, "Expected context to be passed")
end)

test("FireEvent on missing event does nothing", function()
	local se = StatusEffect.new(1, "Burn", nil, 1)
	se:FireEvent("Nope") -- should not error
end)

print("StatusEffect tests complete.")

return true
