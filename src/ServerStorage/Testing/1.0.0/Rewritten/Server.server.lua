--4/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

--[Modules]
local EntityManager = require(ServerScriptService.Testing.EntityManager)



--TODO: TEMPORARY TESTING CODE, GET PLAYER'S DECK FROM THEIR DATASTORE
local DeckLibrary = require(ServerScriptService.DeckLibrary)

local starterDeck = DeckLibrary.CreateDeck(2000)


--[Events]
Players.PlayerAdded:Connect(function(player)
	EntityManager.CreateEntity(player.UserId, player.DisplayName, 100, 100, starterDeck)
end)