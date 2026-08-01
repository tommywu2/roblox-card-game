--4/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

--[Modules]
local EntityLibrary = require(ServerScriptService.Indev.EntityLibrary)





--[Events]
--Players.PlayerAdded:Connect(function(player)
	--EntityLibrary.CreateEntity(2000, {instanceID = player.UserId})
--end)




Players.PlayerAdded:Connect(function(player)
	EntityLibrary.CreatePlayerEntity(2000, player.UserId)
end)