gemai = {}

-- Convert object reference to serializable table.
-- Extend in mods implementing mobs/etc.
-- Returns nil if unable to convert.
function gemai.ref_to_table(obj)
	if obj:is_player() then
		return {type = "player", id = obj:get_player_name()}
	end
end

b.dofile("actions.lua")
b.dofile("context.lua")

b.dofile("entity.lua")
