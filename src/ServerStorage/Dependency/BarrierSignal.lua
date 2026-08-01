local BarrierSignal = {}
BarrierSignal.__index = BarrierSignal

function BarrierSignal.new()
	local self = setmetatable({}, BarrierSignal)
	
	self.listeners = {}
	self.timeout = 10
	
	return self
end

function BarrierSignal:Connect(callback, priority)
	table.insert(self.listeners, {callback = callback, priority = priority})
end

function BarrierSignal:Sort()
	table.sort(self.listeners, function(a, b)
		return a.priority < b.priority
	end)
end

function BarrierSignal:FireAndWait(...)
	self:Sort()
	
	local finished = {}
	
	for _, listener in pairs(self.listeners) do
		local done = {done = false}
		table.insert(finished, {callback = listener.callback, priority = listener.priority, done = done})
		
		task.spawn(function(...)
			local ok, err = pcall(listener.callback, ...)
			
			if not ok then
				warn("BarrierSignal: " .. err)
			end
			
			done.value = true
		end)
	end
	
	for _, connection in pairs(finished) do
		local timeWaited = 0
		
		while connection.done.value == false do
			timeWaited += task.wait()
			if timeWaited >= self.timeout then
				warn("BarrierSignal: Infinite yield possible on " .. tostring(connection.callback))
				break
			end
		end
	end
end

return BarrierSignal