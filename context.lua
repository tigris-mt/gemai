gemai.context = {}

function gemai.context.new(def, data)
	local self = {}

	self.def = b.t.combine({
		global_actions = {},
		global_events = {},
		states = {},
	}, table.copy(def))

	for k,state in pairs(self.def.states) do
		state.events = b.t.combine(self.def.global_events, state.events or {})
		state.actions = b.t.icombine(self.def.global_actions, state.actions or {})
	end

	setmetatable(self, {
		__index = gemai.context,
	})

	self:load(b.t.combine({
		state = "init",
		-- Time since last state change.
		state_time = 0,
		-- Time since context creation.
		live_time = 0,
		-- Delta since last step.
		step_time = 0,
		-- Event queue.
		events = {},
		-- Current event parameters.
		params = {},
	}, data or {}))

	return self
end

function gemai.context:load(data)
	self.data = data
end

function gemai.context:save(data)
	return self.data
end

-- Human readable debug description.
function gemai.context:debug_desc()
	return "unknown"
end

-- Get the current state definition.
function gemai.context:state()
	return self:assert(self.def.states[self.data.state], "no such state: " .. tostring(self.data.state))
end

-- Run an AI step.
-- <dtime> seconds have elapsed since the last step.
function gemai.context:step(dtime)
	-- Update timers.
	self.data.step_time = dtime
	self.data.live_time = self.data.live_time + dtime
	self.data.state_time = self.data.state_time + dtime

	while #self.data.events > 0 do
		-- Pop the next event.
		local event = self.data.events[1]
		table.remove(self.data.events, 1)

		-- Empty string means ignore.
		if self:state().events[event.name] ~= "" then
			-- Update state from according to the event handler.
			self.data.state = self:assert(self:state().events[event.name], "state '" .. self.data.state .. "' does not have event '" .. event.name .. "'")
			-- Update current params.
			self.data.params = event.params
			-- Reset time in state.
			self.data.state_time = 0

			-- If this is a terminating event, clear the remaining queued events.
			if event.terminate then
				self.data.events = {}
			end

			-- Break on the first actionable event we find.
			break
		end
	end

	-- Run all state actions.
	for _,action in ipairs(self:state().actions) do
		self:assert(gemai.actions[action], "gemai action does not exist: " .. action)(self)
		-- If the action inserted a breaking event, don't process any more actions.
		if self.data.events[1] and self.data.events[#self.data.events].break_state then
			break
		end
	end
end

function gemai.context:fire_event(event, params, options)
	local options = b.t.combine({
		-- No events adding before this one will be fired.
		clear = false,
		-- No events added after this one will propagate.
		terminate = true,
		-- This event will stop action processing.
		break_state = true,
	}, options)

	-- If this is a clearing event, clear the previous queued events.
	if options.clear then
		self.data.events = {}
	end

	table.insert(self.data.events, {
		name = event,
		params = params or {},
		terminate = options.terminate,
		break_state = options.break_state,
	})
end

function gemai.context:assert(condition, message)
	local message = (message and (message .. " ") or "") .. "[gemai: " .. self:debug_desc() .. (" %s]"):format(self.data.state)
	if condition then
		return condition
	else
		error(message, 2)
	end
end
