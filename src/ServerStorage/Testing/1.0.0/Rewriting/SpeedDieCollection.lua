--12/07/2026

--[Services]
local ServerScriptService = game:GetService("ServerScriptService")

--[Modules]
local ContainerFactory = require(ServerScriptService.ContainerFactory)
local SpeedDieLibrary = require(ServerScriptService.SpeedDieLibrary)

local SpeedDieCollection = {}
SpeedDieCollection.__index = SpeedDieCollection

--[Constructor]
function SpeedDieCollection.new(owner)
	local self = setmetatable(ContainerFactory.new(), SpeedDieCollection)
	
	self.owner = owner
	
	return self
end

--[Logic]
function SpeedDieCollection:LoadFromLibrary(blueprintIDs)
	self:Clear()
	
	for _, blueprintID in ipairs(blueprintIDs) do
		local speedDie = SpeedDieLibrary.CreateSpeedDie(self.owner, blueprintID)
		if speedDie then
			self:Add(speedDie)
		else
			warn("Failed to load SpeedDie with blueprint ID:", blueprintID)
		end
	end
end

function SpeedDieCollection:RollAll()
	self:ForEach(function(speedDie)
		speedDie:Roll()
	end)
end

function SpeedDieCollection:LockAll()
	self:ForEach(function(speedDie)
		speedDie:Lock()
	end)
end

function SpeedDieCollection:UnlockAll()
	self:ForEach(function(speedDie)
		speedDie:Unlock()
	end)
end

--[Helpers]
function SpeedDieCollection:GetOwner()
	return self.owner
end

return SpeedDieCollection