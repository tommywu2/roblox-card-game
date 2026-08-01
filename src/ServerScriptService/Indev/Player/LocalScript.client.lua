--25/07/2026

--[Services]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[Remotes]
local VoteService = ReplicatedStorage.VoteService


VoteService.OnClientEvent:Connect(function(data)
	if data.type == "vote_start" then
		
	elseif data.type == "vote_end" then
		
	end
end)