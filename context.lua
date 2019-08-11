gemai.context = {}

function gemai.context.new(def, data)
	self.def = b.t.combine({
	}, def)

	setmetatable(self, {
		__index = gemai.context,
	})

	if data then
		self:load(data)
	else
		self:load({})
	end
end

function gemai.context:load(data)
	self.data = data
end

function gemai.context:save(data)
	return self.data
end

-- Run an AI step.
-- <dtime> seconds have elapsed since the last step.
function gemai.context:step(dtime)
end

function gemai.context:fire_event(event, params)
	local params = params or {}
end
