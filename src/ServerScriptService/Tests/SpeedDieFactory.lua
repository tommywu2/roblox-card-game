-- Tests/SpeedDie.spec.lua
local SpeedDie = require(game.ServerScriptService.SpeedDieFactory)
local PileFactory = require(game.ServerScriptService.PileFactory)

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		print("✅ " .. name)
	else
		warn("❌ " .. name .. ": " .. tostring(err))
	end
end

-- Mock owner
local owner = { name = "TestActor" }

-- Mock config
local config = {
	roll = { min = 1, max = 5 },
	energy = { min = 0, max = 10, gain = 2 }
}

-- Constructor
test("new initializes SpeedDie correctly", function()
	local sd = SpeedDie.new(owner, config)

	assert(sd:GetOwner() == owner, "Expected owner to be set")
	assert(sd.roll.min == 1 and sd.roll.max == 5, "Expected roll range 1–5")
	assert(sd.roll.current == 1, "Expected initial roll.current = min")
	assert(sd.energy.current == 0, "Expected initial energy = min")
	assert(sd.assignedPile ~= nil, "Expected assignedPile to exist")
	assert(sd.archivedPile ~= nil, "Expected archivedPile to exist")
end)

-- Energy
test("ChangeEnergy clamps between min and max", function()
	local sd = SpeedDie.new(owner, config)

	sd:ChangeEnergy(5)
	assert(sd:GetEnergy() == 5, "Expected energy = 5")

	sd:ChangeEnergy(100)
	assert(sd:GetEnergy() == 10, "Expected clamped to max = 10")

	sd:ChangeEnergy(-50)
	assert(sd:GetEnergy() == 0, "Expected clamped to min = 0")
end)

test("HasEnergy returns correct boolean", function()
	local sd = SpeedDie.new(owner, config)
	sd:ChangeEnergy(5)
	assert(sd:HasEnergy(3) == true, "Expected HasEnergy(3) = true")
	assert(sd:HasEnergy(10) == false, "Expected HasEnergy(10) = false")
end)

-- Locking
test("Lock and Unlock toggle locked state", function()
	local sd = SpeedDie.new(owner, config)

	assert(sd:IsLocked() == false, "Expected unlocked initially")
	sd:Lock()
	assert(sd:IsLocked() == true, "Expected locked")
	sd:Unlock()
	assert(sd:IsLocked() == false, "Expected unlocked again")
end)

-- Targeting
test("SetTargetSpeedDie and ClearTargetSpeedDie work", function()
	local sd = SpeedDie.new(owner, config)
	local other = SpeedDie.new(owner, config)

	sd:SetTargetSpeedDie(other)
	assert(sd:GetTargetSpeedDie() == other, "Expected target to be set")

	sd:ClearTargetSpeedDie()
	assert(sd:GetTargetSpeedDie() == nil, "Expected target cleared")
end)

-- Roll
test("Roll sets roll.current within range", function()
	local sd = SpeedDie.new(owner, config)

	sd:Roll()
	local v = sd:GetValue()
	assert(v >= 1 and v <= 5, "Expected roll within range")
end)

-- SetValue
test("SetValue sets roll.current", function()
	local sd = SpeedDie.new(owner, config)

	sd:SetValue(4)
	assert(sd:GetValue() == 4, "Expected roll.current = 4")
end)

-- SetRange
test("SetRange updates roll.min and roll.max", function()
	local sd = SpeedDie.new(owner, config)

	sd:SetRange(10, 20)
	assert(sd.roll.min == 10 and sd.roll.max == 20, "Expected range 10–20")
end)

-- AssignCard
test("AssignCard adds card and reduces energy", function()
	local sd = SpeedDie.new(owner, config)
	sd:ChangeEnergy(10)

	local card = { instanceID = 1, cost = 3 }

	sd:AssignCard(card)

	assert(sd:GetEnergy() == 7, "Expected energy reduced by cost")
	assert(sd.assignedPile:Get(1) == card, "Expected card added to assignedPile")
end)

test("AssignCard does nothing when locked", function()
	local sd = SpeedDie.new(owner, config)
	sd:ChangeEnergy(10)
	sd:Lock()

	local card = { instanceID = 1, cost = 3 }
	sd:AssignCard(card)

	assert(sd.assignedPile:Get(1) == nil, "Expected no card added when locked")
end)

test("AssignCard does nothing when insufficient energy", function()
	local sd = SpeedDie.new(owner, config)
	sd:ChangeEnergy(1)

	local card = { instanceID = 1, cost = 3 }
	sd:AssignCard(card)

	assert(sd.assignedPile:Get(1) == nil, "Expected no card added")
end)

-- UnassignCard
test("UnassignCard removes card and refunds energy", function()
	local sd = SpeedDie.new(owner, config)
	sd:ChangeEnergy(7)

	local card = { instanceID = 1, cost = 3 }
	sd.assignedPile:Add(card)

	local removed = sd:UnassignCard(1)

	assert(removed == card, "Expected returned card")
	assert(sd:GetEnergy() == 10, "Expected refunded energy")
	assert(sd.assignedPile:Get(1) == nil, "Expected card removed")
end)

test("UnassignCard removes card and refunds partial energy", function()
	local sd = SpeedDie.new(owner, config)
	sd:ChangeEnergy(8)

	local card = { instanceID = 1, cost = 3 }
	sd.assignedPile:Add(card)

	local removed = sd:UnassignCard(1)

	assert(removed == card, "Expected returned card")
	assert(sd:GetEnergy() == 10, "Expected refunded energy because of energy max")
	assert(sd.assignedPile:Get(1) == nil, "Expected card removed")
end)

test("UnassignCard does nothing when locked", function()
	local sd = SpeedDie.new(owner, config)
	sd:ChangeEnergy(10)

	local card = { instanceID = 1, cost = 3 }
	sd.assignedPile:Add(card)

	sd:Lock()
	local removed = sd:UnassignCard(1)

	assert(removed == nil, "Expected nil when locked")
	assert(sd.assignedPile:Get(1) == card, "Expected card still present")
end)

-- ArchiveCard
test("ArchiveCard moves card from assignedPile to archivedPile", function()
	local sd = SpeedDie.new(owner, config)

	local card = { instanceID = 1, cost = 3 }
	sd.assignedPile:Add(card)

	sd:ArchiveCard(card)

	assert(sd.assignedPile:Get(1) == nil, "Expected card removed from assignedPile")
	assert(sd.archivedPile:Get(1) == card, "Expected card added to archivedPile")
end)

print("SpeedDie tests complete.")

return true
