--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local VoteFactory = require(ServerScriptService.Indev.VoteFactory)

--[Constants]
local VOTE_DURATION = 30

--[Main]
local NodeController = {}
NodeController.__index = NodeController

--[Constructor]
function NodeController.new(node, playerIDs)
	local self = setmetatable({}, NodeController)
	
	self.node = node
	self.vote = VoteFactory.new(playerIDs, node.eventIDs, VOTE_DURATION)
	
	return self
end

--[Functions]
function NodeController:StartVote()
	self.vote:Start()
end

function NodeController:EndVote()
	self.vote:End()
end

function NodeController:Vote(playerID, optionIndex)
	self.vote:Vote(playerID, optionIndex)
end

function NodeController:GetWinner()
	return self.vote:GetWinner()
end

function NodeController:IsResolved()
	return not self.vote:IsActive()
end

return NodeController