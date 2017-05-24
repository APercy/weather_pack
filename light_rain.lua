------------------------------ 
-- Happy Weather: Light Rain

-- License: MIT

-- Credits: xeranas
------------------------------

local light_rain = {}
light_rain.last_check = 0
light_rain.check_interval = 300

-- Weather identification code
light_rain.code = "light_rain"

-- Keeps sound handler references 
local sound_handlers = {}

-- Manual triggers flags
local manual_trigger_start = false
local manual_trigger_end = false

-- Skycolor layer id
local SKYCOLOR_LAYER = "happy_weather_light_rain_sky"

light_rain.is_starting = function(dtime, position)
	if light_rain.last_check + light_rain.check_interval < os.time() then
		light_rain.last_check = os.time()
		if math.random() < 0.15 then
			return true
		end
	end

	if manual_trigger_start then
		manual_trigger_start = false
		return true
	end

	return false
end

light_rain.is_ending = function(dtime)
	if light_rain.last_check + light_rain.check_interval < os.time() then
		light_rain.last_check = os.time()
		if math.random() < 0.5 then
			return true
		end
	end

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
		{r=85, g=86, b=98},
		{r=152, g=150, b=159},
		{r=85, g=86, b=98},
		{r=0, g=0, b=0}
	}
	skylayer.add_layer(player_name, sl)
end

local set_rain_sound = function(player) 
	return minetest.sound_play("light_rain_drop", {
		object = player,
		max_hear_distance = 2,
		loop = true,
	})
end

local remove_rain_sound = function(player)
	local sound = sound_handlers[player:get_player_name()]
	if sound ~= nil then
		minetest.sound_stop(sound)
		sound_handlers[player:get_player_name()] = nil
  	end
end

light_rain.add_player = function(player)
	sound_handlers[player:get_player_name()] = set_rain_sound(player)
	set_sky_box(player:get_player_name())
end

light_rain.remove_player = function(player)
	remove_rain_sound(player)
	skylayer.remove_layer(player:get_player_name(), SKYCOLOR_LAYER)
end

-- Random texture getter
local choice_random_rain_drop_texture = function()
	local texture_name
	local random_number = math.random()
	if random_number > 0.33 then
		texture_name = "happy_weather_light_rain_raindrop_1.png"
	elseif random_number > 0.66 then
		texture_name = "happy_weather_light_rain_raindrop_2.png"
	else
		texture_name = "happy_weather_light_rain_raindrop_3.png"
	end
	return texture_name;
end

local add_rain_particle = function(player)
	local offset = {
		front = 5,
		back = 2,
		top = 4
	}

	local random_pos = hw_utils.get_random_pos(player, offset)

	if hw_utils.is_outdoor(random_pos) then
		minetest.add_particle({
		  pos = {x=random_pos.x, y=random_pos.y, z=random_pos.z},
		  velocity = {x=0, y=-10, z=0},
		  acceleration = {x=0, y=-30, z=0},
		  expirationtime = 2,
		  size = math.random(0.5, 3),
		  collisiondetection = true,
		  collision_removal = true,
		  vertical = true,
		  texture = choice_random_rain_drop_texture(),
		  playername = player:get_player_name()
		})
	end
end

local display_rain_particles = function(player)
	if hw_utils.is_underwater(player) then
		return
	end

	add_rain_particle(player)
end

light_rain.in_area = function(position)
	if position.y > -10 then
		return true
	end
	return false
end

light_rain.render = function(dtime, player)
	display_rain_particles(player)
end

light_rain.start = function()
	manual_trigger_start = true
end

light_rain.stop = function()
	manual_trigger_end = true
end

happy_weather.register_weather(light_rain)