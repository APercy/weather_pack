------------------------------
-- Happy Weather: Light Rain

-- License: MIT

-- Credits: xeranas
------------------------------

local snow = {}

-- Weather identification code
snow.code = "snow"

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end = false

-- Skycolor layer id
local SKYCOLOR_LAYER = "happy_weather_snow_sky"

snow.is_starting = function(dtime, position)
	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end

	return false
end

snow.is_ending = function(dtime)
	if manual_trigger_end then
		manual_trigger_end = false
		return true
	end

	return false
end

local set_sky_box = function(player_name)
	local sl = {}
	sl.layer_type = skylayer.SKY_PLAIN
	sl.name = SKYCOLOR_LAYER
	sl.data = {gradient_data={}}
	sl.data.gradient_data.colors = {
		{r=0, g=0, b=0},
		{r=241, g=244, b=249},
		{r=0, g=0, b=0}
	}
	skylayer.add_layer(player_name, sl)
end

snow.add_player = function(player)
	set_sky_box(player:get_player_name())
end

snow.remove_player = function(player)
	skylayer.remove_layer(player:get_player_name(), SKYCOLOR_LAYER)
end

-- Random texture getter
local choice_random_rain_drop_texture = function()
	local texture_name
	local random_number = math.random()
	if random_number > 0.33 then
		texture_name = "happy_weather_light_snow_snowflake_1.png"
	elseif random_number > 0.66 then
		texture_name = "happy_weather_light_snow_snowflake_2.png"
	else
		texture_name = "happy_weather_light_snow_snowflake_3.png"
	end
	return texture_name;
end

local add_particle = function(player)
	local offset = {
		front = 5,
		back = 2,
		top = 4
	}

	local random_pos = hw_utils.get_random_pos(player, offset)

	if hw_utils.is_outdoor(random_pos) then
		minetest.add_particle({
			pos = {x=random_pos.x, y=random_pos.y, z=random_pos.z},
			velocity = {x = math.random(-1,-0.5), y = math.random(-2,-1), z = math.random(-1,-0.5)},
        	acceleration = {x = math.random(-1,-0.5), y=-0.5, z = math.random(-1,-0.5)},
        	expirationtime = 2.0,
        	size = math.random(0.5, 2),
			collisiondetection = true,
			collision_removal = true,
			vertical = true,
			texture = choice_random_rain_drop_texture(),
			playername = player:get_player_name()
		})
	end
end

local display_particles = function(player)
	if hw_utils.is_underwater(player) then
		return
	end

	add_particle(player)
end

local particles_number_per_update = 10
snow.render = function(dtime, player)
  for i=particles_number_per_update, 1,-1 do
    display_particles(player)
  end
end

snow.start = function()
	manual_trigger_start = true
end

snow.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(snow)