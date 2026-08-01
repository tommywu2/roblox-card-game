--25/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local Vote = require(ServerScriptService.Indev.Models.Voting)

local VoteService = {}
VoteService.__index = VoteService

--[Constructor]
function VoteService.new(voterIDs, candidates, duration)
	local self = setmetatable({}, VoteService)
	
	self.Vote = Vote.new({voterIDs = voterIDs, options = candidates, duration = duration})
	
	return self
end

--[Functions]
function VoteService:Run()
	self.Vote:Start()
	
	while self.Vote:IsActive() do
		task.wait()
	end
	
	return self.Vote:GetWinner()
end

return VoteService