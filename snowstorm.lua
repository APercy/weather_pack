----------------------------
-- Happy Weather: Snowfall

-- License: MIT

-- Credits: xeranas
----------------------------

local snowstorm = {}

-- Weather identification code
snowstorm.code = "snowstorm"
snow.last_check = 0
snow.check_interval = 400
snow.chance = 0.04

-- Keeps sound handler references
local sound_handlers = {}

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end = false

-- Skycolor layer id
local SKYCOLOR_LAYER = "happy_weather_snowstorm_sky"

local set_weather_sound = function(player) 
	return minetest.sound_play("happy_weather_snowstorm", {
		object = player,
		max_hear_distance = 2,
		loop = true,
	})
end

local remove_weather_sound = function(player)
	local sound = sound_handlers[player:get_player_name()]
	if sound ~= nil then
		minetest.sound_stop(sound)
		sound_handlers[player:get_player_name()] = nil
	end
end

snowstorm.is_starting = function(dtime, position)
	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end
	
	return false
end

snowstorm.is_ending = function(dtime)
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
	sl.sky_data = {
		gradient_colors = {
			{r=0, g=0, b=0},
			{r=70, g=70, b=85},
			{r=120, g=120, b=125},
			{r=70, g=70, b=85},
			{r=0, g=0, b=0}
		}
	}
	sl.clouds_data = {
		gradient_colors = {
			{r=10, g=10, b=10},
			{r=65, g=66, b=78},
			{r=112, g=110, b=119},
			{r=65, g=66, b=78},
			{r=10, g=10, b=10}
		},
		speed = {z = 30, y = -80},
		density = 0.6
	}
	skylayer.add_layer(player_name, sl)
end

snowstorm.add_player = function(player)
	sound_handlers[player:get_player_name()] = set_weather_sound(player)
	set_sky_box(player:get_player_name())
end

snowstorm.remove_player = function(player)
	remove_weather_sound(player)
	skylayer.remove_layer(player:get_player_name(), SKYCOLOR_LAYER)
end

local rain_drop_texture = "happy_weather_snowstorm.png"

local sign = function (number)
	if number >= 0 then
		return 1
	else
		return -1
	end
end

local add_wide_range_rain_particle = function(player)
	local offset = {
		front = 7,
		back = 4,
		top = 3,
		bottom = 0
	}

	local random_pos = hw_utils.get_random_pos(player, offset)
	local p_pos = player:getpos()

	local look_dir = player:get_look_dir()

	if hw_utils.is_outdoor(random_pos) then
		minetest.add_particle({
			pos = {x=random_pos.x, y=random_pos.y, z=random_pos.z},
		  	velocity = {x = sign(look_dir.x) * -10, y = -1, z = sign(look_dir.z) * -10},
		  	acceleration = {x = sign(look_dir.x) * -10, y = -1, z = sign(look_dir.z) * -10},
		  	expirationtime = 0.3,
		  	size = 30,
		  	collisiondetection = true,
		  	texture = "happy_weather_snowstorm.png",
		  	playername = player:get_player_name()
		})
	end
end

local display_particles = function(player)
	if hw_utils.is_underwater(player) then
		return
	end

	local particles_number_per_update = 3
	for i=particles_number_per_update, 1,-1 do
		add_wide_range_rain_particle(player)
	end
end

snowstorm.render = function(dtime, player)
	display_particles(player)
end

snowstorm.start = function()
	manual_trigger_start = true
end

snowstorm.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(snowstorm)

