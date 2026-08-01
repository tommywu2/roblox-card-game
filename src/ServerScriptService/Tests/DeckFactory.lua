-- Tests/Deck.spec.lua
local Deck = require(game.ServerScriptService.DeckFactory)
local TableUtils = require(game.ServerScriptService.Dependencies.TableUtils)

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		print("✅ " .. name)
	else
		warn("❌ " .. name .. ": " .. tostring(err))
	end
end

-- Mock TableUtils.copy to ensure deep copy behavior is predictable
local originalCopy = TableUtils.copy
TableUtils.copy = function(tbl)
	local new = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			new[k] = TableUtils.copy(v)
		else
			new[k] = v
		end
	end
	return new
end

-- Constructor
test("new initializes empty deck", function()
	local d = Deck.new()
	assert(d:Count() == 0, "Expected empty deck")
end)

-- Add
test("Add inserts card into deck", function()
	local d = Deck.new()
	local card = { instanceID = 1 }

	d:Add(card)

	assert(d:Count() == 1, "Expected 1 card")
	assert(d.cards[1] == card, "Expected card inserted")
end)

-- Remove
test("Remove deletes card by instanceID and returns it", function()
	local d = Deck.new()
	local cardA = { instanceID = 1 }
	local cardB = { instanceID = 2 }

	d:Add(cardA)
	d:Add(cardB)

	local removed = d:Remove(1)

	assert(removed == cardA, "Expected removed cardA")
	assert(d:Count() == 1, "Expected 1 card left")
	assert(d.cards[1] == cardB, "Expected cardB remaining")
end)

test("Remove returns nil if instanceID not found", function()
	local d = Deck.new()
	d:Add({ instanceID = 1 })

	local removed = d:Remove(999)
	assert(removed == nil, "Expected nil for missing card")
end)

-- RemoveAt
test("RemoveAt removes card at index and returns it", function()
	local d = Deck.new()
	local cardA = { instanceID = 1 }
	local cardB = { instanceID = 2 }

	d:Add(cardA)
	d:Add(cardB)

	local removed = d:RemoveAt(2)

	assert(removed == cardB, "Expected removed cardB")
	assert(d:Count() == 1, "Expected 1 card left")
	assert(d.cards[1] == cardA, "Expected cardA remaining")
end)

test("RemoveAt returns nil for invalid index", function()
	local d = Deck.new()
	local removed = d:RemoveAt(5)
	assert(removed == nil, "Expected nil for invalid index")
end)

-- Get
test("Get returns deep copy of card", function()
	local d = Deck.new()
	local card = { instanceID = 1, data = { value = 10 } }

	d:Add(card)

	local copy = d:Get(1)

	assert(copy ~= card, "Expected different table")
	assert(copy.data.value == 10, "Expected copied data")
end)

test("Get returns nil if instanceID not found", function()
	local d = Deck.new()
	local copy = d:Get(999)
	assert(copy == nil, "Expected nil for missing card")
end)

-- GetAt
test("GetAt returns deep copy of card at index", function()
	local d = Deck.new()
	local card = { instanceID = 1, data = { value = 10 } }

	d:Add(card)

	local copy = d:GetAt(1)

	assert(copy ~= card, "Expected different table")
	assert(copy.data.value == 10, "Expected copied data")
end)

test("GetAt returns nil for invalid index", function()
	local d = Deck.new()
	local copy = d:GetAt(5)
	assert(copy == nil, "Expected nil for invalid index")
end)

-- GetAllCards
test("GetAllCards returns deep copy of deck", function()
	local d = Deck.new()
	local cardA = { instanceID = 1 }
	local cardB = { instanceID = 2 }

	d:Add(cardA)
	d:Add(cardB)

	local copy = d:GetAllCards()

	assert(#copy == 2, "Expected 2 cards")
	assert(copy ~= d.cards, "Expected different table")
	assert(copy[1].instanceID == 1 and copy[2].instanceID == 2, "Expected correct copies")
end)

-- Set
test("Set replaces deck with deep copy of provided cards", function()
	local d = Deck.new()
	local cards = {
		{ instanceID = 1 },
		{ instanceID = 2 }
	}

	d:Set(cards)

	assert(d:Count() == 2, "Expected 2 cards")
	assert(d.cards ~= cards, "Expected deep copy")
end)

-- Clear
test("Clear empties deck", function()
	local d = Deck.new()
	d:Add({ instanceID = 1 })
	d:Add({ instanceID = 2 })

	d:Clear()

	assert(d:Count() == 0, "Expected empty deck")
end)

-- Count
test("Count returns number of cards", function()
	local d = Deck.new()
	assert(d:Count() == 0, "Expected 0 initially")

	d:Add({ instanceID = 1 })
	d:Add({ instanceID = 2 })

	assert(d:Count() == 2, "Expected 2 cards")
end)

-- Shuffle
test("Shuffle randomizes order (sanity check)", function()
	local d = Deck.new()

	local cardA = { instanceID = 1 }
	local cardB = { instanceID = 2 }
	local cardC = { instanceID = 3 }

	d:Add(cardA)
	d:Add(cardB)
	d:Add(cardC)

	local before = { cardA.instanceID, cardB.instanceID, cardC.instanceID }

	d:Shuffle()

	local after = { d.cards[1].instanceID, d.cards[2].instanceID, d.cards[3].instanceID }

	-- Not guaranteed to change, but at least ensure it's a valid permutation
	local seen = {}
	for _, id in ipairs(after) do seen[id] = true end

	assert(seen[1] and seen[2] and seen[3], "Expected valid permutation after shuffle")
end)

print("Deck tests complete.")

-- Restore original TableUtils.copy
TableUtils.copy = originalCopy

return true
