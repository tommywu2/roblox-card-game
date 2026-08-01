--10/07/2026

--Services
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")

--Modules
local SignalManager = require(ServerScriptService.SignalManager)

local StatusEffect = {}
StatusEffect.__index = StatusEffect

--[Constructor]
function StatusEffect.new(statusEffectID, name, description, stacks)
	local self = setmetatable({}, StatusEffect)
	
	self.statusEffectID = statusEffectID
	self.name = name
	self.description = description --Optional description for UI display.
	self.stacks = stacks
	
	self.events = {} --List of events for applying status effect.
	
	return self
end

--[Logic]
function StatusEffect:ChangeStacks(delta: number)
	self.stacks = math.max(self.stacks + delta, 0)
end

--[Events]
function StatusEffect:AddEvent(eventName: string, callback: () -> ())
	if not self.events[eventName] then
		self.events[eventName] = {}
	end
	
	table.insert(self.events[eventName], callback)
end

function StatusEffect:FireEvent(eventName: string, context)
	if not self.events[eventName] then return end

	for _, fn in ipairs(self.events[eventName]) do
		fn(self, context)
	end
end

--[Helpers]
function StatusEffect:GetID()
	return self.statusEffectID
end

function StatusEffect:GetName()
	return self.name
end

function StatusEffect:GetDescription()
	return self.description
end

function StatusEffect:GetStacks()
	return self.stacks
end

function StatusEffect:SetStacks(amount: number)
	self.stacks = math.max(amount, 0)
end

return StatusEffect