function gemai.attach_to_entity(entity, def, data)
	entity._gemai = gemai.context.new(def, data)
	entity._gemai.entity = entity
end
