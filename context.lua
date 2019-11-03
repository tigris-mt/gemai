gemai.context = {}

function gemai.context.new(def, data)
	local self = {}

	self.def = b.t.combine({
		global_actions = {},
		global_events = {},
		states = {},
	}, table.copy(def))

	for k,state in ipairs(self.def.states) do
		state.events = table.combine(self.def.global_events, state.events or {})
		state.actions = table.icombine(self.def.global_actions, state.actions or {})
	end

	setmetatable(self, {
		__index = gemai.context,
	})

	self:load(b.t.combine({
		state = "init",
		state_time = 0,
		live_time = 0,
		events = {},
	}, data or {}))

	return self
end

function gemai.context:load(data)
	self.data = data
end

function gemai.context:save(data)
	return self.data
end

function gemai.context:state()
	return self.def.states[self.data.state]
end

-- Run an AI step.
-- <dtime> seconds have elapsed since the last step.
function gemai.context:step(dtime)
	self.data.live_time = self.data.live_time + dtime
	self.data.state_time = self.data.state_time + dtime

	if #self.data.events > 0 then
		local event = self.data.events[1]
		table.remove(self.data.events, 1)

		self.data.state = self:state().events[event.name]
		self.data.params = event.params
		self.data.state_time = 0

		if event.terminate then
			self.data.events = {}
		end
	end

	for _,action in ipairs(self:state().actions) do
		assert(gemai.actions[action], "gemai action does not exist: " .. action)(self)
	end
end

function gemai.context:fire_event(event, params, options)
	local options = b.t.combine({
		-- No events adding before this one will be fired.
		clear = false,
		-- No events added after this one will propagate.
		terminate = false,
	}, options)

	if options.clear then
		self.data.events = {}
	end

	table.insert(self.data.events, {
		name = event,
		params = params or {},
		terminate = options.terminate,
	})
end
