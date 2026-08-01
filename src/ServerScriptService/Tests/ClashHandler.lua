-- Tests/ClashHandler.spec.lua
local ClashHandler = require(game.ServerScriptService.ClashHandler)

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		print("✅ " .. name)
	else
		warn("❌ " .. name .. ": " .. tostring(err))
	end
end

-- Simple mock container
local function MockContainer(items)
	return {
		items = items or {},
		Count = function(self) return #self.items end,
		GetAt = function(self, index) return self.items[index] end,
		RemoveAt = function(self, index)
			local item = self.items[index]
			table.remove(self.items, index)
			return item
		end
	}
end

-- Mock Move
local function MockMove(name, rolls)
	local idx = 1
	return {
		name = name,
		rolls = rolls or {1},
		GetVariantName = function(self) return self.name end,
		Roll = function(self) end,
		GetValue = function(self) return self.rolls[idx] end,
		OnWin = function() end,
		OnLose = function() end,
		OnDraw = function() end
	}
end

-- Mock Card
local function MockCard(name, moves)
	local index = 1
	return {
		name = name,
		moves = moves,
		HasMovesLeft = function(self)
			return index <= #self.moves
		end,
		GetCurrentMove = function(self)
			return self.moves[index]
		end,
		IncrementMoveIndex = function(self)
			index += 1
		end
	}
end

-- Mock SpeedDie
local function MockSpeedDie(ownerName, assignedCards, targetDie)
	return {
		owner = { name = ownerName },
		assigned = MockContainer(assignedCards),
		GetOwner = function(self) return self.owner end,
		GetAssigned = function(self) return self.assigned end,
		GetTargetDie = function(self) return targetDie end,
		ArchiveCard = function(self, card)
			self.assigned:RemoveAt(1)
		end
	}
end

---------------------------------------------------------------------
-- TESTS
---------------------------------------------------------------------

test("ResolveSpeedDice calls ResolveSpeedDie for each die", function()
	local called = 0

	-- Monkey patch ResolveSpeedDie
	local original = ClashHandler.ResolveSpeedDie
	ClashHandler.ResolveSpeedDie = function(die)
		called += 1
	end

	local d1 = MockSpeedDie("A", {}, nil)
	local d2 = MockSpeedDie("B", {}, nil)

	ClashHandler.ResolveSpeedDice({ d1, d2 })

	assert(called == 2, "Expected ResolveSpeedDie called twice")

	ClashHandler.ResolveSpeedDie = original
end)

test("ResolveSpeedDie does nothing if no target", function()
	local die = MockSpeedDie("A", {}, nil)

	-- Should not error
	ClashHandler.ResolveSpeedDie(die)
end)

test("ResolveSpeedDie resolves clashes until actor has no cards left", function()
	local moveA1 = MockMove("A1", {5})
	local moveA2 = MockMove("A2", {3})
	local cardA = MockCard("ActorCard", {moveA1, moveA2})

	local moveT1 = MockMove("T1", {2})
	local cardT = MockCard("TargetCard", {moveT1})

	local targetDie = MockSpeedDie("Target", {cardT}, nil)
	local actorDie = MockSpeedDie("Actor", {cardA}, targetDie)

	ClashHandler.ResolveSpeedDie(actorDie)

	assert(actorDie:GetAssigned():Count() == 0, "Expected actor card archived")
	assert(targetDie:GetAssigned():Count() == 0, "Expected target card archived")
end)

test("ResolveCard handles actor-only card (no target card)", function()
	local moveA1 = MockMove("A1", {4})
	local moveA2 = MockMove("A2", {1})
	local cardA = MockCard("SoloCard", {moveA1, moveA2})

	local actor = { name = "Actor" }
	local target = { name = "Target" }

	-- Should not error
	ClashHandler.ResolveCard(actor, cardA, target, nil)

	assert(cardA:HasMovesLeft() == false, "Expected all moves consumed")
end)

test("ResolveMove handles win/lose/draw logic", function()
	local winCalled = false
	local loseCalled = false
	local drawCalled = false

	local actorMove = MockMove("ActorMove", {5})
	local targetMove = MockMove("TargetMove", {5})

	actorMove.OnWin = function() winCalled = true end
	actorMove.OnLose = function() loseCalled = true end
	actorMove.OnDraw = function() drawCalled = true end

	targetMove.OnWin = function() end
	targetMove.OnLose = function() end
	targetMove.OnDraw = function() end

	ClashHandler.ResolveMove(
		{ name = "Actor" },
		actorMove,
		{ name = "Target" },
		targetMove
	)

	assert(drawCalled == true, "Expected draw logic triggered")
	assert(winCalled == false, "Expected no win")
	assert(loseCalled == false, "Expected no lose")
end)

print("ClashHandler tests complete.")

return true
