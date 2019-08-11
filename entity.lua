function gemai.attach_to_entity(entity, def, data)
	entity.gemai = gemai.context.new(def, data)
	entity.gemai.entity = entity
end
