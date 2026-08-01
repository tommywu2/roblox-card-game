--25/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

--[Modules]
local EntityFactory = require(ServerScriptService.Indev.Factories.EntityFactory)

--[Connections]
Players.PlayerAdded:Connect(function(player)
	EntityFactory.CreatePlayerEntity(1, player.UserId)
end)