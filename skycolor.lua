skycolor = {
	-- Should be activated before do any effect.
	active = false,
	
	-- Update interval.
	update_interval = 15,

	-- Main sky colors: starts from midnight to midnight.
	colors = {},

	-- Update sky color. If players not specified update sky for all players.
	update_sky_color = function(players) 
		local timeofday = minetest.get_timeofday()
		local rounded_time = math.floor(timeofday * 1000)
		local color = skycolor.utils.convert_to_rgb(0, 1000, rounded_time, skycolor.colors)

		if players == nil or #players == 0 then
			players = minetest.get_connected_players()
		end
		for _, player in ipairs(players) do
			player:set_sky(color, "plain", nil)
		end

	end,

	-- Reset sky color to game default. If players not specified update sky for all players.
	set_default_sky = function(players)
		if players == nil or #players == 0 then
			players = minetest.get_connected_players()
		end
		for _, player in ipairs(players) do
			player:set_sky(nil, "regular", nil)
		end
	end,

	utils = {
		convert_to_rgb = function(minval, maxval, current_val, colors)
			local max_index = #colors - 1
			local val = (current_val-minval) / (maxval-minval) * max_index + 1.0
			local index1 = math.floor(val)
			local index2 = math.min(math.floor(val)+1, max_index + 1)
			local f = val - index1
			local c1 = colors[index1]
			local c2 = colors[index2]
			return {r=math.floor(c1.r + f*(c2.r - c1.r)), g=math.floor(c1.g + f*(c2.g-c1.g)), b=math.floor(c1.b + f*(c2.b - c1.b))}
		end
	},

}

local timer = -1
minetest.register_globalstep(function(dtime)	
	if skycolor.active ~= true then
		return
	end

	-- exceptional first time update
	if timer <= 0 then
		skycolor.update_sky_color()
		timer = 0
		return
	end

	-- regular updates based on iterval
	timer = timer + dtime;
	if timer >= skycolor.update_interval then
		skycolor.update_sky_color()
		timer = 0
	end

end)