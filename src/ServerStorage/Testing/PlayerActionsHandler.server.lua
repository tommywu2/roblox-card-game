--Services
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Modules
local EntityManager = require(ServerScriptService.Testing.EntityManager)

--Remotes
local GetHand = ReplicatedStorage:WaitForChild("GetHand")
local GetSpeedDice = ReplicatedStorage:WaitForChild("GetSpeedDice")

GetHand.OnServerInvoke = function(player)
	return EntityManager.GetAll()[player.UserId]:GetHand():GetAllCards()
end

GetSpeedDice.OnServerInvoke = function(player)
	return EntityManager.GetAll()[player.UserId]:GetSpeedDice()
end
