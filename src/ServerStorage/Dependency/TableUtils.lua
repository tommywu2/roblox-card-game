--!strict
--[[
	Author - RobloxJrTrainer
	
	TableUtils utility module for anything involving tables, that Roblox doesn't already include.
]]

local TableUtils = {}

local random = Random.new()

local ERROR_MESSAGES = {
	tbl = "Expected a table, got ",
	num = "Expected a number, got ",
	func = "Expected a function, got ",
	boolean = "Expected a boolean, got ",
	nilCheck = "Expected any non-nil type, got nil"
}

--[[
	Creates a copy of the given table. If deep is true (default), recursively copies all nested tables.
	If deep is false, performs a shallow copy using table.clone.
	
	@param templateTbl - T: The table to copy
	@param deep - boolean?: Whether to perform deep copy (default: true)
	@return T: A new copy of the table
	
	Example:
	```lua
	local original = {a = 1, b = {c = 2}}
	local deepCopy = TableUtils.copy(original) -- Creates new nested tables
	local shallowCopy = TableUtils.copy(original, false) -- Shares reference to nested table
	```
]]
function TableUtils.copy<T>(templateTbl: T, deep: boolean?): T
	-- If deep is false, then return a shallow copy
	if deep == false then 
		return (table.clone(templateTbl :: any) :: any) :: T
	end
	local function deepCopy(t: {any})
		local tCopy = table.clone(t)
		for k, v in pairs(tCopy) do
			if type(v) == "table" then
				tCopy[k] = deepCopy(v)
			end
		end
		return tCopy
	end
	return deepCopy(templateTbl :: any) :: T  
end

--[[
	Synchronizes 'source' to match the structure of 'template', ensuring data conforms to expected
	structure while preserving valid values. Removes extra keys and adds missing ones.
	
	@param source - T: The source table to synchronize
	@param template - U: The template table to match structure against
	@return U: A new table matching template structure with preserved valid values
	
	Example:
	```lua
	local template = {name = "", age = 0, settings = {volume = 50}}
	local userData = {name = "John", age = 25, invalidKey = "remove", settings = {volume = 75, theme = "dark"}}
	local synced = TableUtils.sync(userData, template)
	-- Result: {name = "John", age = 25, settings = {volume = 75}}
	-- Notice: invalidKey removed, theme removed from settings
	```
]]
function TableUtils.sync<T, U>(source: T, template: U): U
	assert(type(source) == "table", `{ERROR_MESSAGES.tbl}'{source}'`)
	assert(type(template) == "table", `{ERROR_MESSAGES.tbl}'{template}'`)
	local result: {[any]: any} = {}
	-- Helper function that automatically checks type and copies
	local function copyValue(value: any): any
		if type(value) == "table" then
			return TableUtils.copy(value, true)
		else
			return value
		end
	end
	-- Process all keys from template (ensures we get all required keys)
	for templateKey, templateValue in pairs(template) do
		local sourceValue = source[templateKey]
		-- Is the key missing?
		if sourceValue == nil then
			-- Add from template
			result[templateKey] = copyValue(templateValue)
			-- Is there a type mismatch?
		elseif type(sourceValue) ~= type(templateValue) then
			-- Use template value
			result[templateKey] = copyValue(templateValue)
			-- Are they both tables?
		elseif type(sourceValue) == "table" and type(templateValue) == "table" then
			-- Recursively sync
			result[templateKey] = TableUtils.sync(sourceValue, templateValue)
		else
			-- Same type not table so keep source value
			result[templateKey] = sourceValue
		end
	end
	return (result :: any) :: U
end

--[[
	Synchronizes 'source' to match 'template', but does not remove keys. Useful
	for player data where you want to preserve extra keys while ensuring required structure.
	
	@param source - T: The source table to reconcile
	@param template - U: The template table to match structure against
	@return T & U: A new table with preserved keys plus template structure
	
	Example:
	```lua
	local template = {coins = 0, level = 1}
	local playerData = {coins = 500, customSkin = "rare", level = "invalid"}
	local reconciled = TableUtils.reconcile(playerData, template)
	-- Result: {coins = 500, customSkin = "rare", level = 1}
	-- Notice: customSkin preserved, level fixed to correct type
	```
]]
function TableUtils.reconcile<T, U>(source: T, template: U): T & U
	assert(type(source) == "table", `{ERROR_MESSAGES.tbl}'{source}'`)
	assert(type(template) == "table", `{ERROR_MESSAGES.tbl}'{template}'`)
	local result = table.clone(source :: any)
	-- Helper function that automatically checks type and copies
	local function copyValue(value: any): any
		if type(value) == "table" then
			return TableUtils.copy(value, true)
		else
			return value
		end
	end
	-- Process existing keys from source
	for sourceKey, sourceValue in pairs(result) do
		local templateValue = template[sourceKey]
		-- Is there a type mismatch?
		if type(sourceValue) ~= type(templateValue) then
			-- Is template value not nil?
			if templateValue ~= nil then
				-- Use template value
				result[sourceKey] = copyValue(templateValue)
			end
			-- Are they both tables?
		elseif type(sourceValue) == "table" and type(templateValue) == "table" then
			-- Recursively reconcile
			result[sourceKey] = TableUtils.reconcile(sourceValue, templateValue)
		end
		-- Else: same type and not table, keep source value
	end
	-- Add missing keys from template
	for templateKey, templateValue in pairs(template) do
		local sourceValue = result[templateKey]
		-- Is the key missing?
		if sourceValue == nil then
			-- Add from template
			result[templateKey] = copyValue(templateValue)
		end
	end
	return (result :: any) :: T & U
end

--[[
	Creates a new array with elements in reverse order.
	
	@param array - T: The array table to be reversed
	@return T: A new table that is reversed from the original
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4}
	local reversed = TableUtils.reverse(numbers)
	-- Result: {4, 3, 2, 1}
	```
]]
function TableUtils.reverse<T>(array: T): T
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	local reversed = {}
	for i = #array, 1, -1 do
		table.insert(reversed, array[i])
	end
	return (reversed :: any) :: T
end

--[[
	Creates a new array with randomly shuffled elements using the provided Random instance.
	
	@param array - {T}: The array to shuffle
	@param random - Random: The Random instance from Random.new() with optional seed
	@return {T}: A new shuffled array
	
	Example:
	```lua
	local cards = {"A", "K", "Q", "J"}
	local shuffled = TableUtils.shuffle(cards, Random.new(12345))
	-- Result: randomly ordered array like {"Q", "A", "J", "K"}
	```
]]
function TableUtils.shuffle<T>(array: {T}, random: Random): {T}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	local shuffled: {T} = table.clone(array)
	random:Shuffle(shuffled)
	return shuffled
end

--[[
	Finds the last occurrence of a value in an array, starting from an optional index.
	Uses deep equality for table comparisons.
	
	@param array - T: The array to search
	@param value - any: The value to find
	@param init - number?: Starting index for search (default: 1)
	@return number | nil: Index of last occurrence, or nil if not found
	
	Example:
	```lua
	local items = {"apple", "banana", "apple", "orange"}
	local lastApple = TableUtils.findLast(items, "apple")
	-- Result: 3 (the index of the last "apple")
	```
]]
function TableUtils.findLast<T>(array: T, value: any, init: number?): number | nil
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(value ~= nil, ERROR_MESSAGES.nilCheck)
	if init then
		assert(type(init) == "number", `{ERROR_MESSAGES.num}'{init}'`)
	end
	-- Store an occurrence variable
	local lastIndex = nil -- Start at nil
	local init = init or 1
	for i = init, #array, 1 do
		local vArray = array[i]
		if TableUtils.deepEqual(vArray, value) then
			lastIndex = i
		end
	end
	return lastIndex
end

--[[
	Finds the first element in an array that satisfies the predicate function.
	
	@param array - {T}: The array to search
	@param predicate - function: Function that takes (index, value) and returns boolean
	@return T?: The first matching element, or nil if none found
	
	Example:
	```lua
	local players = {{name = "Alice", score = 95}, {name = "Bob", score = 87}}
	local highScorer = TableUtils.findWhere(players, function(i, player)
		return player.score > 90
	end)
	-- Result: {name = "Alice", score = 95}
	```
]]
function TableUtils.findWhere<T>(array: {T}, predicate: (i: number, v: any) -> boolean): T?
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(predicate) == "function", `{ERROR_MESSAGES.func}'{predicate}'`)
	for i, v in ipairs(array) do
		local result = predicate(i, v)
		-- Check if 'result' is infact a boolean, if it is not, error
		assert(type(result) == "boolean", `{ERROR_MESSAGES.boolean}'{result}'`)
		if result then
			return v
		end
	end
	return nil
end

--[[
	Performs deep equality comparison between two values/tables.
	For non-table values, uses standard == comparison.
	For tables, recursively compares all keys and values.
	
	@param t1 - T: First value/table to compare
	@param t2 - U: Second value/table to compare
	@return boolean: True if deeply equal, false otherwise
	
	Example:
	```lua
	local obj1 = {a = 1, b = {c = 2}}
	local obj2 = {a = 1, b = {c = 2}}
	local obj3 = {a = 1, b = {c = 3}}
	print(TableUtils.deepEqual(obj1, obj2)) -- true
	print(TableUtils.deepEqual(obj1, obj3)) -- false
	```
]]
function TableUtils.deepEqual<T, U>(t1: T, t2: U): boolean
	if type(t1) ~= "table" or type(t2) ~= "table" then
		-- Directly compare
		return t1 == t2
	end
	-- Do both tables have same keys and values?
	for k, v in pairs(t1) do
		if not TableUtils.deepEqual(v, t2[k]) then
			return false
		end
	end
	for k, v in pairs(t2) do
		if not TableUtils.deepEqual(v, t1[k]) then
			return false
		end
	end
	return true
end

--[[
	Checks if a table contains a specific value. Works for both arrays and dictionaries.
	Optionally performs deep search through nested tables.
	
	@param tbl - T: The table to search (array or dictionary)
	@param value - any: The value to find
	@param deep - boolean?: Whether to search nested tables (default: false)
	@return boolean: True if value found, false otherwise
	
	Example:
	```lua
	local data = {a = 1, b = {c = 2}}
	print(TableUtils.contains(data, 1))        -- true
	print(TableUtils.contains(data, 2))        -- false
	print(TableUtils.contains(data, 2, true))  -- true (found in nested table)
	```
]]
function TableUtils.contains<T>(tbl: T, value: any, deep: boolean?): boolean
	assert(type(tbl) == "table", `{ERROR_MESSAGES.tbl}'{tbl}'`)
	assert(value ~= nil, ERROR_MESSAGES.nilCheck)
	-- First check using table.find
	-- If it is not nil, then we found an array part of 'tbl' so we return true
	if table.find(tbl, value) then
		return true
	end
	-- 'tbl' must be a dictionary
	for _, tblV in pairs(tbl) do
		-- Check if 'v' is equal to 'value'
		if tblV == value then
			return true
		end
		if deep == true then
			-- Check if it is a table
			if type(tblV) == "table" then
				if type(value) ~= "table" then
					return TableUtils.contains(tblV, value, true)
				else
					-- 'value' IS a table, check if these 2 tables are equal
					return TableUtils.deepEqual(tblV, value)
				end
			end
		end
	end
	-- If we get here, it does not contain 'value'
	return false
end

--[[
	Counts how many times a value appears in a table.
	Optionally counts occurrences in nested tables using deep comparison.
	
	@param tbl - T: The table to search
	@param value - any: The value to count
	@param deep - boolean?: Whether to count in nested tables (default: false)
	@return number: Number of occurrences found
	
	Example:
	```lua
	local data = {1, 2, 1, {nested = 1}}
	print(TableUtils.count(data, 1))        -- 2
	print(TableUtils.count(data, 1, true))  -- 3 (includes nested occurrence)
	```
]]
function TableUtils.count<T>(tbl: T, value: any, deep: boolean?): number
	assert(type(tbl) == "table", `{ERROR_MESSAGES.tbl}'{tbl}'`)
	assert(value ~= nil, ERROR_MESSAGES.nilCheck)
	local ct = 0 -- Start at 0
	for _, tblV in pairs(tbl) do
		-- Direct compare
		if tblV == value then
			ct += 1
		elseif deep == true and type(tblV) == "table" then
			if type(value) ~= "table" then
				ct += TableUtils.count(tblV, value, true)
			else
				-- If they are both tables, use `deepEqual`
				if TableUtils.deepEqual(tblV, value) then
					ct += 1 -- Increments by 1
				end
			end
		end
	end
	return ct
end

--[[
	Transforms each element in an array using a transform function and returns a new array.
	
	@param array - {T}: The array to transform
	@param transform - function: Function that takes a value and returns transformed value
	@return {U}: New array with transformed elements
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4}
	local doubled = TableUtils.map(numbers, function(n) return n * 2 end)
	-- Result: {2, 4, 6, 8}
	```
]]
function TableUtils.map<T, U>(array: {T}, transform: (T) -> U): {U}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(transform) == "function", `{ERROR_MESSAGES.func}'{transform}'`)
	local result: {U} = {}
	for _, v in ipairs(array) do
		table.insert(result, transform(v))
	end
	return result
end

--[[
	Creates a new array containing only elements that pass the predicate test.
	
	@param array - {T}: The array to filter
	@param predicate - function: Function that takes (index, value) and returns boolean
	@return {T}: New array with elements that passed the test
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4, 5}
	local evens = TableUtils.filter(numbers, function(i, n) return n % 2 == 0 end)
	-- Result: {2, 4}
	```
]]
function TableUtils.filter<T>(array: {T}, predicate: (i: number, v: T) -> boolean): {T}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(predicate) == "function", `{ERROR_MESSAGES.func}'{predicate}'`)
	local filtered = {}
	for i, v in ipairs(array) do
		local result = predicate(i, v)
		-- Check if 'result' is infact a boolean, if it is not, error
		assert(type(result) == "boolean", `{ERROR_MESSAGES.boolean}'{result}'`)
		if result then
			-- Add to 'filtered'
			table.insert(filtered, v)
		end
	end
	return filtered
end

--[[
	Creates a new array containing only elements that fail the predicate test.
	Opposite of filter - returns elements that don't match the condition.
	
	@param array - {T}: The array to process
	@param predicate - function: Function that takes (index, value) and returns boolean
	@return {T}: New array with elements that failed the test
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4, 5}
	local odds = TableUtils.reject(numbers, function(i, n) return n % 2 == 0 end)
	-- Result: {1, 3, 5} (rejected the even numbers)
	```
]]
function TableUtils.reject<T>(array: {T}, predicate: (i: number, v: T) -> boolean): {T}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(predicate) == "function", `{ERROR_MESSAGES.func}'{predicate}'`)
	local rejected = {}
	for i, v in ipairs(array) do
		local result = predicate(i, v)
		-- Check if 'result' is infact a boolean, if it is not, error
		assert(type(result) == "boolean", `{ERROR_MESSAGES.boolean}'{result}'`)
		if not result then
			-- Add to 'rejected'
			table.insert(rejected, v)
		end
	end
	return rejected
end

--[[
	Reduces an array to a single value by iteratively applying a reducer function.
	If no initialValue is provided, uses the first array element as the starting value.
	
	@param array - {T}: The array to reduce
	@param reducer - function: Function that takes (accumulator, currentValue, index, array) and returns new accumulator
	@param initialValue - any: Starting value for accumulator (optional)
	@return U: The final accumulated value
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4}
	local sum = TableUtils.reduce(numbers, function(acc, val) return acc + val end, 0)
	-- Result: 10
	
	local words = {"Hello", "World"}
	local sentence = TableUtils.reduce(words, function(acc, word) return acc .. " " .. word end)
	-- Result: "Hello World"
	```
]]
function TableUtils.reduce<T, U>(
	array: {T},
	reducer: (accumulator: U, currentValue: T, currentIndex: number, originalArray: {T}) -> U,
	initialValue: any
): U
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(reducer) == "function", `{ERROR_MESSAGES.func}'{reducer}'`)
	-- Check if the table is empty
	if #array == 0 then
		if initialValue ~= nil then
			return initialValue
		else
			error("Reduce of empty array with no initial value")
		end
	end
	local accumulator
	local startIndex
	-- Determine starting values
	if initialValue ~= nil then
		accumulator = initialValue
		startIndex = 1
	else
		accumulator = array[1]
		startIndex = 2
	end
	-- Iterate through the array
	for i = startIndex, #array do
		accumulator = reducer(accumulator, array[i], i, array)
	end
	return accumulator
end

--[[
	Flattens a nested array to a specified depth. Arrays within arrays are "flattened" 
	by moving their elements up one level.
	
	@param array - {T | {any}}: The nested array to flatten
	@param depth - number?: How many levels deep to flatten (default: 1)
	@return {T}: New flattened array
	
	Example:
	```lua
	local nested = {1, {2, 3}, {4, {5, 6}}}
	local flat1 = TableUtils.flatten(nested)
	-- Result: {1, 2, 3, 4, {5, 6}} (depth 1)
	
	local flat2 = TableUtils.flatten(nested, 2)
	-- Result: {1, 2, 3, 4, 5, 6} (depth 2)
	```
]]
function TableUtils.flatten<T>(array: {T | {any}}, depth: number?): {T}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	local flattenDepth = depth or 1
	local result: {T} = {}
	local function flattenRecursive(arr: {any}, currentDepth: number)
		for _, val in ipairs(arr) do
			if type(val) == "table" and currentDepth > 0 then
				-- Recursively flatten if it's a table and we havent reached max depth
				flattenRecursive(val, currentDepth - 1)
			else
				-- Add the value (either not a table, or we've reached max depth)
				table.insert(result, val)
			end
		end
	end
	flattenRecursive(array, flattenDepth)
	return result
end

--[[
	Creates a new array with duplicate values removed. Uses deep comparison for tables.
	Preserves the order of first occurrence of each unique element.
	
	@param array - {T}: The array to remove duplicates from
	@return {T}: New array with unique elements only
	
	Example:
	```lua
	local numbers = {1, 2, 2, 3, 1, 4}
	local unique = TableUtils.unique(numbers)
	-- Result: {1, 2, 3, 4}
	
	local objects = {{id = 1}, {id = 2}, {id = 1}}
	local uniqueObjects = TableUtils.unique(objects)
	-- Result: {{id = 1}, {id = 2}} (deep comparison removes duplicate)
	```
]]
function TableUtils.unique<T>(array: {T}): {T}
	local result: {T} = {}
	local function alreadySeen(newValue: any): boolean
		for _, existingValue in ipairs(result) do
			if TableUtils.deepEqual(newValue, existingValue) then
				return true
			end
		end
		return false
	end
	for _, v in ipairs(array) do
		if not alreadySeen(v) then
			table.insert(result, v)
		end
	end
	return result
end

--[[
	Extracts a portion of an array from startIndex to endIndex (inclusive).
	Similar to string.sub but for arrays.
	
	@param array - {T}: The array to slice
	@param startIndex - number: Starting index (1-based)
	@param endIndex - number?: Ending index (default: end of array)
	@return {T}: New array containing the slice
	
	Example:
	```lua
	local letters = {"a", "b", "c", "d", "e"}
	local slice = TableUtils.slice(letters, 2, 4)
	-- Result: {"b", "c", "d"}
	```
]]
function TableUtils.slice<T>(array: {T}, startIndex: number, endIndex: number?): {T}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(startIndex) == "number", `{ERROR_MESSAGES.num}'{startIndex}'`)
	local endIndex = endIndex or #array
	-- If 'endIndex' is less than or greater than 'startIndex', error, as this is not possible.
	assert(endIndex >= startIndex, `'endIndex' cannot be less than the 'startIndex' - '{endIndex}' < '{startIndex}'`)
	local sliced: {T} = {}
	for i = startIndex, endIndex do
		-- Insert this 'arrayValue' into 'sliced'
		table.insert(sliced, array[i])
	end
	return sliced
end

--[[
	Splits an array into smaller arrays (chunks) of a specified maximum size, in a shallow table.
	Useful for processing large datasets in smaller batches.
	
	@param array - {T}: The array to split into chunks
	@param size - number: Maximum size of each chunk
	@return {{T}}: Array of chunk arrays
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4, 5, 6, 7}
	local chunks = TableUtils.chunk(numbers, 3)
	-- Result: {{1, 2, 3}, {4, 5, 6}, {7}}
	```
]]
function TableUtils.chunk<T>(array: {T}, size: number): {{T}}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(size) == "number", `{ERROR_MESSAGES.num}'{size}'`)
	local chunks: {{T}} = {}
	-- Loop through 'array', and either use an existing chunk that is less than our 'size',
	-- or create a new table with the 'size'
	for _, v in ipairs(array) do
		-- Get the latest chunk
		local lastChunk = chunks[#chunks]
		-- Is this last chunk nil, or is it already full?
		if lastChunk == nil or #lastChunk >= size then
			-- Insert a new table, with the value inside of it
			table.insert(chunks, {v})
			-- Else, this chunk can be used (not nil, and the size of lastChunk is less than our 'size')
		else
			table.insert(lastChunk, v)
		end
	end
	return chunks
end

--[[
	Returns a new array containing the first n elements from the original array.
	
	@param array - {T}: The array to take from
	@param count - number: Number of elements to take
	@return {T}: New array with first n elements
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4, 5}
	local first3 = TableUtils.take(numbers, 3)
	-- Result: {1, 2, 3}
	```
]]
function TableUtils.take<T>(array: {T}, count: number): {T}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(count) == "number", `{ERROR_MESSAGES.num}'{count}'`)
	local result: {T} = {}
	for i = 1, count do
		table.insert(result, array[i])
	end
	return result
end

--[[
	Returns a new array with the first n elements removed (skipped).
	
	@param array - {T}: The array to drop from
	@param count - number: Number of elements to skip
	@return {T}: New array without first n elements
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4, 5}
	local without2 = TableUtils.drop(numbers, 2)
	-- Result: {3, 4, 5}
	```
]]
function TableUtils.drop<T>(array: {T}, count: number): {T}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(count) == "number", `{ERROR_MESSAGES.num}'{count}'`)
	if count >= #array then
		return {}
	end
	local result: {T} = {}
	-- Start at 'count' index, end at the end of the array
	for i = count + 1, #array do
		table.insert(result, array[i])
	end
	return result
end

--[[
	Returns a new array containing the last n elements from the original array.
	
	@param array - {T}: The array to take from
	@param count - number: Number of elements to take from the end
	@return {T}: New array with last n elements
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4, 5}
	local last3 = TableUtils.takeLast(numbers, 3)
	-- Result: {3, 4, 5}
	```
]]
function TableUtils.takeLast<T>(array: {T}, count: number): {T}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(count) == "number", `{ERROR_MESSAGES.num}'{count}'`)
	if count <= 0 then
		-- Return an empty array
		return {}
	end
	if count >= #array then
		return table.clone(array)
	end
	local result: {T} = {}
	local startIndex = #array - count + 1
	-- Iterate backward in the array, starting at the size of array
	for i = startIndex, #array do
		table.insert(result, array[i])
	end
	return result
end

--[[
	Returns a new array with the last n elements removed.
	
	@param array - {T}: The array to drop from
	@param count - number: Number of elements to remove from the end
	@return {T}: New array without last n elements
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4, 5}
	local withoutLast2 = TableUtils.dropLast(numbers, 2)
	-- Result: {1, 2, 3}
	```
]]
function TableUtils.dropLast<T>(array: {T}, count: number): {T}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(count) == "number", `{ERROR_MESSAGES.num}'{count}'`)
	if count <= 0 or count >= #array then
		return table.clone(array)
	end
	local result: {T} = {}
	local endIndex = #array - count
	for i = 1, endIndex do
		table.insert(result, array[i])
	end
	return result
end

--[[
	Combines multiple arrays into a single new array. Elements are added in order.
	
	@param ... - {T}: Variable number of arrays to combine
	@return {T}: New array containing all elements from input arrays
	
	Example:
	```lua
	local arr1 = {1, 2}
	local arr2 = {3, 4}
	local arr3 = {5, 6}
	local combined = TableUtils.concat(arr1, arr2, arr3)
	-- Result: {1, 2, 3, 4, 5, 6}
	```
]]
function TableUtils.concat<T>(...: {T}): {T}
	local arrays = {...}
	local result: {T} = {}
	-- Loop through each array
	for _, array in ipairs(arrays) do
		assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
		-- Loop through every value in this array
		for _, value in ipairs(array) do
			table.insert(result, value)
		end
	end
	return result
end

--[[
	Combines arrays element-wise into tuples. Creates pairs/triplets/etc from corresponding indices.
	Stops when the shortest array is exhausted.
	
	@param ... - {any}: Variable number of arrays to zip together
	@return {{any}}: Array of tuples containing elements from corresponding positions
	
	Example:
	```lua
	local names = {"Alice", "Bob", "Charlie"}
	local ages = {25, 30, 35}
	local cities = {"NYC", "LA"}
	local zipped = TableUtils.zip(names, ages, cities)
	-- Result: {{"Alice", 25, "NYC"}, {"Bob", 30, "LA"}}
	-- Note: Charlie is omitted because cities array is shorter
	```
]]
function TableUtils.zip(...: {any}): {{any}}
	local arrays = {...}
	-- Find the minimum length among all arrays
	local minLength = math.huge
	for _, array in arrays do
		-- Validate all arguments are tables first
		assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
		minLength = math.min(minLength, #array)
	end
	local result: {{any}} = {}
	-- Create tuples for each index up to minLength
	for i = 1, minLength do
		local tuple = {}
		-- Fill out 'tuple'
		for _, array in ipairs(arrays) do
			table.insert(tuple, array[i])
		end
		-- Insert our tuple into result
		table.insert(result, tuple)
	end
	return result
end

--[[
	Splits an array into two arrays based on a predicate function.
	Elements that satisfy the predicate go into the first array (truthy),
	elements that don't go into the second array (falsy).
	
	@param array - {T}: The array to partition
	@param predicate - function: Function that takes (index, value) and returns boolean
	@return ({T}, {T}): Two arrays - (truthy, falsy)
	
	Example:
	```lua
	local numbers = {1, 2, 3, 4, 5, 6}
	local evens, odds = TableUtils.partition(numbers, function(i, n) return n % 2 == 0 end)
	-- evens: {2, 4, 6}
	-- odds: {1, 3, 5}
	```
]]
function TableUtils.partition<T>(array: {T}, predicate: (i: number, v: T) -> boolean): ({T}, {T})
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(predicate) == "function", `{ERROR_MESSAGES.func}'{predicate}'`)
	local truthy: {T} = {}
	local falsy: {T} = {}
	-- Loop through 'array' in order and compare with predicate
	for i, v in ipairs(array) do
		local result = predicate(i, v)
		-- Check if 'result' is in fact a boolean, if it is not, error
		assert(type(result) == "boolean", `{ERROR_MESSAGES.boolean}'{result}'`)
		if result then
			table.insert(truthy, v)
		else
			table.insert(falsy, v)
		end
	end
	return truthy, falsy
end

--[[
	Removes index i in the array by swapping the value at i with the last value, then trimming off last value.
	This is a classic O(1) operation that doesn't preserve order.
	@param array - {T}: The array to modify (mutates original)
	@param index - number: Index to remove
	Example:
	```lua
	local items = {"A", "B", "C", "D", "E"}
	TableUtils.swapRemove(items, 2) -- Remove "B"
	-- items is now: {"A", "E", "C", "D"}
	```
]]
function TableUtils.swapRemove<T>(array: {T}, index: number): ()
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(index) == "number" and index % 1 == 0, `{ERROR_MESSAGES.num}'{index}'`)
	assert(index >= 1 and index <= #array, `Index {index} out of bounds for array of length {#array}`)
	local n = #array
	array[index] = array[n]
	array[n] = nil
end

--[[
	Extracts all keys from a dictionary and returns them as an array.
	
	@param dict - {[K]: V}: The dictionary to extract keys from
	@return {K}: Array containing all keys
]]
function TableUtils.keys<K, V>(dict: {[K]: V}): {K}
	assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
	local result: {K} = {}
	for key, _ in pairs(dict) do
		table.insert(result, key)
	end
	return result
end

--[[
	Extracts all values from a dictionary and returns them as an array.
	
	@param dict - {[K]: V}: The dictionary to extract values from
	@return {V}: Array containing all values
]]
function TableUtils.values<K, V>(dict: {[K]: V}): {V}
	assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
	local result: {V} = {}
	for _, value in pairs(dict) do
		table.insert(result, value)
	end
	return result
end

--[[
	Converts a dictionary into an array of [key, value] pairs.
	
	@param dict - {[K]: V}: The dictionary to convert
	@return {{any}}: Array of [key, value] pairs
	
	Example:
	```lua
	local scores = {Alice = 95, Bob = 87}
	local entries = TableUtils.entries(scores)
	-- Result: {{"Alice", 95}, {"Bob", 87}}
	```
]]
function TableUtils.entries<K, V>(dict: {[K]: V}): {{any}}
	assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
	local result: {{any}} = {}
	for k, v in pairs(dict) do
		table.insert(result, {k, v :: any})
	end
	return result
end

--[[
	Creates a new dictionary with keys and values swapped. 
	Throws an error if any value is a table (since tables make poor keys).
	
	@param dict - {[K]: V}: The dictionary to invert
	@return {[V]: K}: New dictionary with swapped keys and values
	
	Example:
	```lua
	local userRoles = {john = "admin", jane = "user"}
	local roleUsers = TableUtils.invert(userRoles)
	-- Result: {admin = "john", user = "jane"}
	```
]]
function TableUtils.invert<K, V>(dict: {[K]: V}): {[V]: K}
	assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
	local result: {[V]: K} = {}
	for k, v in pairs(dict) do
		assert(type(v) ~= "table", `Cannot invert dictionary: value at key '{k}' is a table (tables should not be used as keys)`)
		result[v] = k
	end
	return result
end

--[[
	Creates a new dictionary containing only the specified keys from the original.
	Keys that don't exist in the original are ignored.
	
	@param dict - {[K]: V}: The source dictionary
	@param keys - {K}: Array of keys to include
	@return {[K]: V}: New dictionary with only the picked keys
	
	Example:
	```lua
	local user = {name = "John", age = 25, password = "secret", email = "john@example.com"}
	local publicInfo = TableUtils.pick(user, {"name", "age", "email"})
	-- Result: {name = "John", age = 25, email = "john@example.com"}
	```
]]
function TableUtils.pick<K, V>(dict: {[K]: V}, keys: {K}): {[K]: V}
	assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
	assert(type(keys) == "table", `{ERROR_MESSAGES.tbl}'{keys}'`)
	local result: {[K]: V} = {}
	for _, keyLike in ipairs(keys) do
		local value = dict[keyLike]
		if value ~= nil then
			result[keyLike] = value
		end
	end
	return result
end

--[[
	Creates a new dictionary excluding the specified keys from the original.
	
	@param dict - {[K]: V}: The source dictionary
	@param keys - {K}: Array of keys to exclude
	@return {[K]: V}: New dictionary without the omitted keys
	
	Example:
	```lua
	local user = {name = "John", age = 25, password = "secret"}
	local safeUser = TableUtils.omit(user, {"password"})
	-- Result: {name = "John", age = 25}
	```
]]
function TableUtils.omit<K, V>(dict: {[K]: V}, keys: {K}): {[K]: V}
	assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
	assert(type(keys) == "table", `{ERROR_MESSAGES.tbl}'{keys}'`)
	local result: {[K]: V} = {}
	for k, v in pairs(dict) do
		-- Is this key excluded according to 'keys'?
		local keyLikeIndex = table.find(keys, k)
		if keyLikeIndex and keys[keyLikeIndex] then
			-- Skip this one, as it is excluded
			continue
		end		
		result[k] = v
	end
	return result
end

--[[
	Creates a new dictionary with all keys transformed by the given function.
	Values remain unchanged. Throws error if transform returns a table (bad key type).
	
	@param dict - {[K]: V}: The source dictionary
	@param transform - function: Function that takes a key and returns new key
	@return {[U]: V}: New dictionary with transformed keys
	
	Example:
	```lua
	local scores = {alice = 95, bob = 87}
	local upperScores = TableUtils.mapKeys(scores, function(name) return string.upper(name) end)
	-- Result: {ALICE = 95, BOB = 87}
	```
]]
function TableUtils.mapKeys<K, V, U>(dict: {[K]: V}, transform: (K) -> U): {[U]: V}
	assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
	assert(type(transform) == "function", `{ERROR_MESSAGES.func}'{transform}'`)
	local result: {[U]: V} = {}
	for k, v in pairs(dict) do
		local newKey = transform(k)
		-- Check if newKey is a table (impractible key type)
		assert(type(newKey) ~= "table", `Transform function returned a table for key '{k}' (tables should not be used as keys)`)
		result[newKey] = v
	end
	return result
end

--[[
	Creates a new dictionary with all values transformed by the given function.
	Keys remain unchanged.
	
	@param dict - {[K]: V}: The source dictionary
	@param transform - function: Function that takes a value and returns new value
	@return {[K]: U}: New dictionary with transformed values
	
	Example:
	```lua
	local prices = {apple = 1.50, banana = 0.75}
	local taxedPrices = TableUtils.mapValues(prices, function(price) return price * 1.1 end)
	-- Result: {apple = 1.65, banana = 0.825}
	```
]]
function TableUtils.mapValues<K, V, U>(dict: {[K]: V}, transform: (V) -> U): {[K]: U}
	assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
	assert(type(transform) == "function", `{ERROR_MESSAGES.func}'{transform}'`)
	local result: {[K]: U} = {}
	for k, v in pairs(dict) do
		local newValue = transform(v)
		result[k] = newValue
	end
	return result
end

--[[
	Creates a new dictionary containing only key-value pairs that pass the predicate test.
	
	@param dict - {[K]: V}: The dictionary to filter
	@param predicate - function: Function that takes (key, value) and returns boolean
	@return {[K]: V}: New dictionary with entries that passed the test
	
	Example:
	```lua
	local inventory = {apples = 50, bananas = 0, oranges = 25}
	local inStock = TableUtils.filterKeyValues(inventory, function(item, count) return count > 0 end)
	-- Result: {apples = 50, oranges = 25}
	```
]]
function TableUtils.filterKeyValues<K, V>(dict: {[K]: V}, predicate: (key: K, value: V) -> boolean): {[K]: V}
	assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
	assert(type(predicate) == "function", `{ERROR_MESSAGES.func}'{predicate}'`)
	local result: {[K]: V} = {}
	for k, v in pairs(dict) do
		local keep = predicate(k, v)
		assert(type(keep) == "boolean", `{ERROR_MESSAGES.boolean}'{keep}'`)
		if keep then
			result[k] = v
		end
	end
	return result
end

--[[
	Returns the total number of key-value pairs in a table.
	Works for both arrays and dictionaries. More reliable than # operator for mixed tables.
]]
function TableUtils.size(tbl: {[any]: any}): number
	assert(type(tbl) == "table", `{ERROR_MESSAGES.tbl}'{tbl}'`)
	local count = 0
	for _ in pairs(tbl) do
		count += 1
	end
	return count
end

--[[
	Combines multiple dictionaries into a new dictionary. Later dictionaries override earlier ones.
	Performs a shallow merge - nested tables are replaced entirely, not merged.
	
	@param ... - {[any]: any}: Variable number of dictionaries to merge
	@return {[any]: any}: New merged dictionary
	
	Example:
	```lua
	local defaults = {color = "blue", size = "medium"}
	local userPrefs = {color = "red", style = "bold"}
	local merged = TableUtils.merge(defaults, userPrefs)
	-- Result: {color = "red", size = "medium", style = "bold"}
	```
]]
function TableUtils.merge(...: {[any]: any}): {[any]: any}
	local dicts = {...}
	local result: {[any]: any} = {}
	for _, dict in pairs(dicts) do
		assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
		-- Copy all key-value pairs from this dict
		for k, v in pairs(dict) do
			result[k] = v
		end
	end
	return result
end

--[[
	Deeply merges multiple dictionaries. When both dictionaries have the same key with table values,
	those nested tables are merged recursively rather than replaced.
	
	@param ... - {[any]: any}: Variable number of dictionaries to merge
	@return {[any]: any}: New deeply merged dictionary
	
	Example:
	```lua
	local config1 = {database = {host = "localhost", port = 5432}}
	local config2 = {database = {user = "admin"}, logging = true}
	local merged = TableUtils.mergeDeep(config1, config2)
	-- Result: {database = {host = "localhost", port = 5432, user = "admin"}, logging = true}
	```
]]
function TableUtils.mergeDeep(...: {[any]: any}): {[any]: any}
	local dicts = {...}
	local result: {[any]: any} = {}
	-- Process each dict in order
	for _, dict in ipairs(dicts) do
		assert(type(dict) == "table", `{ERROR_MESSAGES.tbl}'{dict}'`)
		-- Deep merge all key-value pairs from this dict
		for k, v in pairs(dict) do
			local existingValue = result[k]
			-- Are both values table?
			if type(existingValue) == "table" and type(v) == "table" then
				-- Recursive merge
				result[k] = TableUtils.mergeDeep(existingValue, v)
			else
				-- Either not both tables or no existing value - use the new value
				-- Copy if it's a table to avoid reference sharing
				if type(v) == "table" then
					result[k] = TableUtils.copy(v, true)
				else
					result[k] = v
				end
			end
		end
	end
	return result
end

--[[
	Checks if a table contains no elements. Works for both arrays and dictionaries.
]]
function TableUtils.isEmpty(tbl: {[any]: any}): boolean
	assert(type(tbl) == "table", `{ERROR_MESSAGES.tbl}'{tbl}'`)
	return TableUtils.size(tbl) == 0
end

--[[
	Checks if a table is array-like (has numeric indices starting from 1).
	Returns false for empty tables.
]]
function TableUtils.isArray(tbl: {[any]: any}): boolean
	assert(type(tbl) == "table", `{ERROR_MESSAGES.tbl}'{tbl}'`)
	return #tbl ~= 0
end

--[[
	Determines the specific type of table structure.
	
	@param tbl - {[any]: any}: The table to analyze
	@return "array" | "dict" | "mixed" | "empty": The table type
	
	Example:
	```lua
	print(TableUtils.getType({}))           -- "empty"
	print(TableUtils.getType({1, 2, 3}))    -- "array"
	print(TableUtils.getType({a = 1}))      -- "dict"
	print(TableUtils.getType({1, a = 2}))   -- "mixed"
	```
]]
function TableUtils.getType(tbl: {[any]: any}): "array" | "dict" | "mixed" | "empty"
	assert(type(tbl) == "table", `{ERROR_MESSAGES.tbl}'{tbl}'`)
	-- First, check if it is an array
	if TableUtils.isEmpty(tbl) then
		return "empty"
	end
	-- Check if it has array part
	local arrayResemblance = TableUtils.isArray(tbl)
	-- If no arrayResemblance, it's a dictionary
	if not arrayResemblance then
		return "dict"
	end
	-- Has array part but not a dict - check if it's pure array or mixed
	local length = #tbl
	local totalSize = TableUtils.size(tbl)
	-- Is total size equal to array length?
	if totalSize == length then
		return "array"
	else
		return "mixed"
	end
end

--[[
	Inserts a value into a sorted array while maintaining sorted order using binary search.
	Modifies the original array (imperative operation).
	
	@param sortedArray - {T}: The sorted array to insert into
	@param value - T: The value to insert
	@param compareFunction - function?: Custom comparison function (default: ascending order)
	@return number: The index where the value was inserted
	
	Example:
	```lua
	local scores = {65, 75, 85, 95}
	local insertedAt = TableUtils.sortedInsert(scores, 80)
	-- scores is now: {65, 75, 80, 85, 95}
	-- insertedAt: 3
	```
]]
function TableUtils.sortedInsert<T>(sortedArray: {T}, value: T, compareFunction: ((T, T) -> boolean)?): number
	assert(type(sortedArray) == "table", `{ERROR_MESSAGES.tbl}'{sortedArray}'`)
	if compareFunction then
		assert(type(compareFunction) == "function", `{ERROR_MESSAGES.func}'{compareFunction}'`)
	end
	-- Default comparison function (ascending order)
	local compare: (T, T) -> boolean
	if compareFunction then
		compare = compareFunction
	else
		compare = function(a, b)
			return (a :: any) < b
		end
	end
	-- Binary search to find insertion position
	local left = 1
	local right = #sortedArray + 1
	while left < right do
		local mid = math.floor((left + right) / 2)
		-- Is sortedArray[mid] < value?
		if compare(sortedArray[mid], value) then
			left = mid + 1
		else
			right = mid
		end
	end
	table.insert(sortedArray, left, value)
	return left
end

--[[
	Checks if an array is sorted according to the comparison function.
	
	@param array - {T}: The array to check
	@param compareFunction - function?: Custom comparison function (default: ascending order)
	@return boolean: True if array is sorted, false otherwise
	
	Example:
	```lua
	print(TableUtils.isSorted({1, 2, 3, 4}))    -- true
	print(TableUtils.isSorted({1, 3, 2, 4}))    -- false
	print(TableUtils.isSorted({4, 3, 2, 1}, function(a, b) return a > b end))  -- true (descending)
	```
]]
function TableUtils.isSorted<T>(array: {T}, compareFunction: ((T, T) -> boolean)?): boolean
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	if compareFunction then
		assert(type(compareFunction) == "function", `{ERROR_MESSAGES.func}'{compareFunction}'`)
	end
	-- Default comparison function (ascending order)
	local compare: any = compareFunction or function(a, b)
		return (a :: any) < (b :: any)
	end
	-- Check each adjacent pair
	for i = 1, #array - 1 do
		-- If current element is greater than next element then its not sorted
		if not compare(array[i], array[i + 1]) and array[i] ~= array[i + 1] then
			return false
		end
	end
	return true
end

--[[
	Combines two arrays and returns unique elements from both (set union operation).
	
	@param array1 - {T}: First array
	@param array2 - {T}: Second array
	@return {T}: New array with unique elements from both arrays
	
	Example:
	```lua
	local team1 = {"Alice", "Bob", "Charlie"}
	local team2 = {"Bob", "David", "Eve"}
	local allPlayers = TableUtils.union(team1, team2)
	-- Result: {"Alice", "Bob", "Charlie", "David", "Eve"}
	```
]]
function TableUtils.union<T>(array1: {T}, array2: {T}): {T}
	assert(type(array1) == "table", `{ERROR_MESSAGES.tbl}'{array1}'`)
	assert(type(array2) == "table", `{ERROR_MESSAGES.tbl}'{array2}'`)
	local combined = TableUtils.concat(array1, array2)
	-- Remove dupes
	return TableUtils.unique(combined)
end

--[[
	Returns elements that exist in both arrays (set intersection operation).
	
	@param array1 - {T}: First array
	@param array2 - {T}: Second array
	@return {T}: New array with elements common to both arrays
	
	Example:
	```lua
	local skills1 = {"programming", "design", "testing"}
	local skills2 = {"design", "management", "testing"}
	local commonSkills = TableUtils.intersection(skills1, skills2)
	-- Result: {"design", "testing"}
	```
]]
function TableUtils.intersection<T>(array1: {T}, array2: {T}): {T}
	assert(type(array1) == "table", `{ERROR_MESSAGES.tbl}'{array1}'`)
	assert(type(array2) == "table", `{ERROR_MESSAGES.tbl}'{array2}'`)
	local result: {T} = {}
	-- Check each element in array1 to see if it exists in array2
	for _, value in ipairs(array1) do
		-- Is this value in array2 and not already present in result?
		if TableUtils.contains(array2, value) and not TableUtils.contains(result, value) then
			table.insert(result, value)
		end
	end
	return result
end

--[[
	Returns elements that exist in the first array but not the second (set difference operation).
	
	@param array1 - {T}: First array
	@param array2 - {T}: Second array  
	@return {T}: New array with elements only in first array
	
	Example:
	```lua
	local allTasks = {"code", "test", "deploy", "document"}
	local completedTasks = {"code", "test"}
	local remainingTasks = TableUtils.difference(allTasks, completedTasks)
	-- Result: {"deploy", "document"}
	```
]]
function TableUtils.difference<T>(array1: {T}, array2: {T}): {T}
	assert(type(array1) == "table", `{ERROR_MESSAGES.tbl}'{array1}'`)
	assert(type(array2) == "table", `{ERROR_MESSAGES.tbl}'{array2}'`)
	local result: {T} = {}
	-- Check each element in array1
	for _, value in ipairs(array1) do
		-- Is this value NOT in array2 and not already in result?
		if not TableUtils.contains(array2, value) and not TableUtils.contains(result, value) then
			table.insert(result, value)
		end
	end
	return result
end

--[[
	Returns elements that exist in either array but not in both (symmetric difference).
	
	@param array1 - {T}: First array
	@param array2 - {T}: Second array
	@return {T}: New array with elements in either array but not both
	
	Example:
	```lua
	local frontend = {"React", "Vue", "CSS"}
	local backend = {"Node", "Vue", "SQL"}  
	local exclusive = TableUtils.symmetricDifference(frontend, backend)
	-- Result: {"React", "CSS", "Node", "SQL"} (Vue is in both, so excluded)
	```
]]
function TableUtils.symmetricDifference<T>(array1: {T}, array2: {T}): {T}
	assert(type(array1) == "table", `{ERROR_MESSAGES.tbl}'{array1}'`)
	assert(type(array2) == "table", `{ERROR_MESSAGES.tbl}'{array2}'`)
	-- Get elements in array1 but not array2
	local diff1 = TableUtils.difference(array1, array2)
	-- Get elements in array2 but not array1
	local diff2 = TableUtils.difference(array2, array1)
	-- Combine the differences
	return TableUtils.concat(diff1, diff2)
end

--[[
	Groups array elements by the result of calling keyFunction on each element.
	
	@param array - {T}: The array to group
	@param keyFunction - function: Function that takes an element and returns a grouping key
	@return {[any]: {T}}: Dictionary where keys are group identifiers and values are arrays of grouped elements
	
	Example:
	```lua
	local students = {
		{name = "Alice", grade = "A"},
		{name = "Bob", grade = "B"}, 
		{name = "Charlie", grade = "A"}
	}
	local byGrade = TableUtils.groupBy(students, function(student) return student.grade end)
	-- Result: {A = {{name = "Alice", grade = "A"}, {name = "Charlie", grade = "A"}}, B = {{name = "Bob", grade = "B"}}}
	```
]]
function TableUtils.groupBy<T>(array: {T}, keyFunction: (T) -> any): {[any]: {T}}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(keyFunction) == "function", `{ERROR_MESSAGES.func}'{keyFunction}'`)
	local result: {[any]: {T}} = {}
	-- Process each element
	for _, value in ipairs(array) do
		local key = keyFunction(value)
		-- Create group if it doesn't exist
		if result[key] == nil then
			result[key] = {}
		end
		-- Add element to group
		table.insert(result[key], value)
	end
	return result
end

--[[
	Counts elements by the result of calling keyFunction on each element.
	
	@param array - {T}: The array to count
	@param keyFunction - function: Function that takes an element and returns a counting key
	@return {[any]: number}: Dictionary where keys are categories and values are counts
	
	Example:
	```lua
	local fruits = {"apple", "banana", "apple", "orange", "banana", "apple"}
	local counts = TableUtils.countBy(fruits, function(fruit) return fruit end)
	-- Result: {apple = 3, banana = 2, orange = 1}
	```
]]
function TableUtils.countBy<T>(array: {T}, keyFunction: (T) -> any): {[any]: number}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(keyFunction) == "function", `{ERROR_MESSAGES.func}'{keyFunction}'`)
	local result: {[any]: number} = {}
	-- Process each element
	for _, value in ipairs(array) do
		local key = keyFunction(value)
		-- Increment count for this key
		result[key] = (result[key] or 0) + 1
	end
	return result
end

--[[
	Finds the element with the maximum value returned by keyFunction.
	
	@param array - {T}: The array to search
	@param keyFunction - function: Function that takes an element and returns a comparable value
	@return T?: The element with maximum key value, or nil if array is empty
	
	Example:
	```lua
	local players = {{name = "Alice", score = 95}, {name = "Bob", score = 87}, {name = "Charlie", score = 102}}
	local topPlayer = TableUtils.maxBy(players, function(player) return player.score end)
	-- Result: {name = "Charlie", score = 102}
	```
]]
function TableUtils.maxBy<T>(array: {T}, keyFunction: (T) -> any): T?
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(keyFunction) == "function", `{ERROR_MESSAGES.func}'{keyFunction}'`)
	if #array == 0 then
		return nil
	end
	local maxElement = array[1]
	local maxKey = keyFunction(maxElement)
	-- Compare with the remaining elementws
	for i = 2, #array do
		local element = array[i]
		local key = keyFunction(element)
		-- Is this key greater than current max?
		if key > maxKey then
			maxElement = element
			maxKey = key
		end
	end
	return maxElement
end

--[[
	Finds the element with the minimum value returned by keyFunction.
	
	@param array - {T}: The array to search
	@param keyFunction - function: Function that takes an element and returns a comparable value
	@return T?: The element with minimum key value, or nil if array is empty
	
	Example:
	```lua
	local products = {{name = "Laptop", price = 999}, {name = "Mouse", price = 25}, {name = "Keyboard", price = 75}}
	local cheapest = TableUtils.minBy(products, function(product) return product.price end)
	-- Result: {name = "Mouse", price = 25}
	```
]]
function TableUtils.minBy<T>(array: {T}, keyFunction: (T) -> any): T?
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(keyFunction) == "function", `{ERROR_MESSAGES.func}'{keyFunction}'`)
	if #array == 0 then
		return nil
	end
	local minElement = array[1]
	local minKey = keyFunction(minElement)
	-- Compare with the remaining elements
	for i = 2, #array do
		local element = array[i]
		local key = keyFunction(element)
		-- Is this key less than current min?
		if key < minKey then
			minElement = element
			minKey = key
		end
	end
	return minElement
end

--[[
	Returns a random sample of elements from the array without replacement.
	
	@param array - {T}: The array to sample from
	@param count - number?: Number of elements to sample (default: 1)
	@return {T}: New array with randomly selected elements
	
	Example:
	```lua
	local colors = {"red", "blue", "green", "yellow", "purple"}
	local randomColors = TableUtils.sample(colors, 3)
	-- Result: 3 randomly selected colors, e.g., {"green", "red", "purple"}
	```
]]
function TableUtils.sample<T>(array: {T}, count: number?): {T}
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	if count then
		assert(type(count) == "number", `{ERROR_MESSAGES.num}'{count}'`)
	end
	local sampleCount = count or 1
	-- Dont sample more than array size
	sampleCount = math.min(sampleCount, #array)
	if sampleCount <= 0 then
		return {}
	end
	-- Shuffle array and take first n elements
	local shuffled = TableUtils.shuffle(array, random)
	return TableUtils.take(shuffled, sampleCount)
end

--[[
	Tests whether all elements pass the predicate test.
	
	@param array - {T}: The array to test
	@param predicate - function: Function that takes (index, value) and returns boolean
	@return boolean: True if all elements pass, false if any element fails
	
	Example:
	```lua
	local scores = {85, 92, 78, 95}
	local allPassing = TableUtils.every(scores, function(i, score) return score >= 70 end)
	-- Result: true (all scores are 70 or above)
	```
]]
function TableUtils.every<T>(array: {T}, predicate: (i: number, v: T) -> boolean): boolean
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(predicate) == "function", `{ERROR_MESSAGES.func}'{predicate}'`)
	-- Check each
	for i, v in ipairs(array) do
		local result = predicate(i, v)
		assert(type(result) == "boolean", `{ERROR_MESSAGES.boolean}'{result}'`)
		-- If atleast 1 element fails, return false
		if not result then
			return false
		end
	end
	-- All elements passed
	return true
end

--[[
	Tests whether at least one element passes the predicate test.
	
	@param array - {T}: The array to test
	@param predicate - function: Function that takes (index, value) and returns boolean
	@return boolean: True if any element passes, false if no elements pass
	
	Example:
	```lua
	local temperatures = {15, 22, 8, 30, 12}
	local hasHotDay = TableUtils.some(temperatures, function(i, temp) return temp > 25 end)
	-- Result: true (30 degrees is above 25)
	```
]]
function TableUtils.some<T>(array: {T}, predicate: (i: number, v: T) -> boolean): boolean
	assert(type(array) == "table", `{ERROR_MESSAGES.tbl}'{array}'`)
	assert(type(predicate) == "function", `{ERROR_MESSAGES.func}'{predicate}'`)
	-- Check each
	for i, v in ipairs(array) do
		local result = predicate(i, v)
		assert(type(result) == "boolean", `{ERROR_MESSAGES.boolean}'{result}'`)
		-- If any element passes, return true
		if result then
			return true
		end
	end
	-- No elements passed
	return false
end

return TableUtils
