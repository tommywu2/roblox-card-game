--21/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local EntityRegistry = require(ServerScriptService.Indev.Registries.EntityRegistry)
local Node = require(ServerScriptService.Indev.Models.Node)
local EventFactory = require(ServerScriptService.Indev.Factories.EventFactory)


local VoteService = require(ServerScriptService.Indev.Services.VoteService)

--[Testing]
local node = Node.new({title = "test", eventIDs = {1000, 2000, 3000}})

local voteService = VoteService.new(EntityRegistry.GetPlayerIDs(), node:GetEventIDs(), 10)
print(voteService)
local winner = voteService:Run()



local event = EventFactory.CreateEvent(winner)

local voteService = VoteService.new(EntityRegistry.GetPlayerIDs(), event:GetOptions(), 10)
print(voteService)
local winner = voteService:Run()
print(winner)


if winner.outcome.variant == "Combat" then
	print("TODO: Implement combat scene.")
elseif winner.outcome.variant == "Shop" then
	print("TODO: Implement shop scene.")
end