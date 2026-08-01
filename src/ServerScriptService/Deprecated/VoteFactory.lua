--20/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

--[Modules]


--[Main]
local Vote = {}
Vote.__index = Vote

--[Constructor]
function Vote.new(voterIDs: {}, choiceIDs: {}, duration: number)
	local self = setmetatable({}, Vote)
	
	self.voterIDs = voterIDs
	self.choiceIDs = choiceIDs
	self.duration = duration
	self.votes = {}
	self.results = {}
	
	self.heartbeatConnection = nil
	
	return self
end

--[Functions]
function Vote:Vote(voterID, optionIndex)
	if not self.active then warn("Vote is not active") return end
	if not table.find(self.voterIDs, voterID) then warn("Invalid voter ID") return end
	if not self.choiceIDs[optionIndex] then warn("Invalid choice index") return end
	
	self.votes[voterID] = optionIndex
end

function Vote:Start()
	self.active = true
	
	self.heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self.duration -= deltaTime
		
		if self.duration <= 0 then
			self:End()
		end
	end)
end

function Vote:End()
	self.heartbeatConnection:Disconnect()
	self.active = false
	self.winner = self:GetWinner()
end

function Vote:GetWinner()
	self.results = {}
	
	for choiceIndex, choiceID in ipairs(self.choiceIDs) do
		self.results[choiceIndex] = 0
	end
	
	for voterID, choiceIndex in pairs(self.votes) do
		self.results[choiceIndex] += 1
	end
	
	local winnerIndex = 1
	
	for choiceIndex, votes in pairs(self.results) do
		if votes > self.results[winnerIndex] then
			winnerIndex = choiceIndex
		end
	end

	return self.choiceIDs[winnerIndex]
end

function Vote:GetDuration()
	return self.duration
end

function Vote:IsActive()
	return self.active
end

return Vote