--21/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

--[Modules]

--[Main]
local Voting = {}
Voting.__index = Voting

--[Constructor]
function Voting.new(data: {})
	local self = setmetatable({}, Voting)

	self.voterIDs = data.voterIDs
	self.options = data.options
	self.duration = data.duration
	self.votes = {}
	self.results = {}

	self.heartbeatConnection = nil

	return self
end

--[Functions]
function Voting:Start()
	self.active = true
	
	self.heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self.duration -= deltaTime

		if self.duration <= 0 then
			self:End()
		end
	end)
end

function Voting:End()
	self.heartbeatConnection:Disconnect()
	self.active = false
	self.winner = self:GetWinner()
end

function Voting:Vote(voterID, optionIndex)
	if not self.active then warn("Vote is not active") return end
	if not table.find(self.voterIDs, voterID) then warn("Invalid voter ID") return end
	if not self.options[optionIndex] then warn("Invalid option index") return end

	self.votes[voterID] = optionIndex
end

function Voting:GetWinner()
	self.results = {}

	for choiceIndex, choiceID in ipairs(self.options) do
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

	return self.options[winnerIndex]
end

function Voting:GetDuration()
	return self.duration
end

function Voting:IsActive()
	return self.active
end

return Voting