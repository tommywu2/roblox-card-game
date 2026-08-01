-- Tests/SpeedDieCollection.spec.lua
local SpeedDieCollection = require(game.ServerScriptService.SpeedDieCollection)
local SpeedDieLibrary = require(game.ServerScriptService.SpeedDieLibrary)

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

-- Mock SpeedDieLibrary behavior
-- Override CreateSpeedDie for testing
local originalCreate = SpeedDieLibrary.CreateSpeedDie

SpeedDieLibrary.CreateSpeedDie = function(owner, blueprintID)
	if blueprintID == "valid1" then
		return { id = "valid1", owner = owner, Roll = function() end, Lock = function() end, Unlock = function() end }
	elseif blueprintID == "valid2" then
		return { id = "valid2", owner = owner, Roll = function() end, Lock = function() end, Unlock = function() end }
	end
	return nil
end

-- Constructor
test("new initializes SpeedDieCollection with owner", function()
	local c = SpeedDieCollection.new(owner)
	assert(c:GetOwner() == owner, "Expected owner to be set")
	assert(c:Count() == 0, "Expected empty collection initially")
end)

-- LoadFromLibrary
test("LoadFromLibrary loads valid speed dice", function()
	local c = SpeedDieCollection.new(owner)

	c:LoadFromLibrary({ "valid1", "valid2" })

	assert(c:Count() == 2, "Expected 2 speed dice loaded")

	local all = c:GetAll()
	assert(all[1].id == "valid1", "Expected first die = valid1")
	assert(all[2].id == "valid2", "Expected second die = valid2")
end)

test("LoadFromLibrary clears previous contents", function()
	local c = SpeedDieCollection.new(owner)

	c:LoadFromLibrary({ "valid1" })
	assert(c:Count() == 1, "Expected 1 item")

	c:LoadFromLibrary({ "valid2" })
	assert(c:Count() == 1, "Expected previous items cleared")
	assert(c:GetAll()[1].id == "valid2", "Expected only valid2 present")
end)

test("LoadFromLibrary skips invalid blueprint IDs", function()
	local c = SpeedDieCollection.new(owner)

	c:LoadFromLibrary({ "valid1", "invalid", "valid2" })

	assert(c:Count() == 2, "Expected only valid IDs loaded")
end)

-- RollAll
test("RollAll calls Roll on each SpeedDie", function()
	local called = 0

	SpeedDieLibrary.CreateSpeedDie = function(owner, id)
		return {
			id = id,
			Roll = function() called += 1 end,
			Lock = function() end,
			Unlock = function() end
		}
	end

	local c = SpeedDieCollection.new(owner)
	c:LoadFromLibrary({ "valid1", "valid2" })

	c:RollAll()

	assert(called == 2, "Expected Roll called twice")
end)

-- LockAll
test("LockAll calls Lock on each SpeedDie", function()
	local locked = 0

	SpeedDieLibrary.CreateSpeedDie = function(owner, id)
		return {
			id = id,
			Roll = function() end,
			Lock = function() locked += 1 end,
			Unlock = function() end
		}
	end

	local c = SpeedDieCollection.new(owner)
	c:LoadFromLibrary({ "valid1", "valid2" })

	c:LockAll()

	assert(locked == 2, "Expected Lock called twice")
end)

-- UnlockAll
test("UnlockAll calls Unlock on each SpeedDie", function()
	local unlocked = 0

	SpeedDieLibrary.CreateSpeedDie = function(owner, id)
		return {
			id = id,
			Roll = function() end,
			Lock = function() end,
			Unlock = function() unlocked += 1 end
		}
	end

	local c = SpeedDieCollection.new(owner)
	c:LoadFromLibrary({ "valid1", "valid2" })

	c:UnlockAll()

	assert(unlocked == 2, "Expected Unlock called twice")
end)

print("SpeedDieCollection tests complete.")

-- Restore original CreateSpeedDie
SpeedDieLibrary.CreateSpeedDie = originalCreate

return true
