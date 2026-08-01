local IDManager = {}

local currentID = 0

function IDManager.generateID()
	currentID += 1
	
	return currentID
end

return IDManager