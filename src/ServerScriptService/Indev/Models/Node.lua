--21/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local Voting = require(ServerScriptService.Indev.Models.Voting)

--[Main]
local Node = {}
Node.__index = Node

--[Constructor]
function Node.new(data)
	local self = setmetatable({}, Node)

	self.title = data.title

	self.eventIDs = data.eventIDs
	self.voting = Voting.new({voterIDs = {1001, 1002}, choiceIDs = self.eventIDs, duration = 10}) --TEMPORARY DATA
	return self
end

--[Functions]
function Node:StartVoting()
	self.voting:Start()
end

function Node:EndVoting()
	self.voting:End()
end

function Node:Vote(voterID, optionIndex)
	self.voting:Vote(voterID, optionIndex)
end

function Node:IsVotingActive()
	return self.voting:IsActive()
end

function Node:GetVotingWinner()
	return self.voting:GetWinner()
end

function Node:GetEventIDs()
	return self.eventIDs
end

return Node
