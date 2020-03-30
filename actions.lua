gemai.actions = {}

function gemai.register_action(name, value)
	gemai.actions[name] = value
end

gemai.register_action("gemai:always", function(self)
	self:fire_event("gemai:always")
end)
