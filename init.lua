gemai = {}

-- Convert object reference to serializable table.
-- Returns nil if unable to convert.
function gemai.ref_to_table(obj)
	if obj:is_player() then
		return {type = "player", id = obj:get_player_name()}
	elseif obj:get_luaentity() and obj:get_luaentity()._aurum_mobs_id then
		return {type = "aurum_mob", id = obj:get_luaentity()._aurum_mobs_id}
	end
end

b.dofile("actions.lua")
b.dofile("context.lua")

b.dofile("entity.lua")
