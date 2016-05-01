weather = {
  -- weather states, 'none' is default, other states depends from active mods
  state = "none",
  
  -- player list for saving player meta info
  players = {},
  
  -- time when weather should be re-calculated
  next_check = 0,
  
  -- default weather recalculation interval
  check_interval = 300,
  
  -- weather min duration
  min_duration = 240,
  
  -- weather max duration
  max_duration = 3600,
  
  -- weather calculated end time
  end_time = nil,
  
  -- registered weathers
  known_weathers = {}
}

weather.get_rand_end_time = function()
  return os.time() + math.random(weather.min_duration, weather.max_duration);
end

-- checks if player is undewater. This is needed in order to
-- turn off weather particles generation.
function is_underwater(player)
    local ppos = player:getpos()
    local offset = player:get_eye_offset()
    local player_eye_pos = {x = ppos.x + offset.x, 
                            y = ppos.y + offset.y + 1.5, 
                            z = ppos.z + offset.z}
    
    if minetest.get_node_level(player_eye_pos) == 8 then
      return true
    end
    return false
end

-- returns random number between a and b.
function random_pos(a, b)
  if (a > b) then
    return math.random(b, a);
  end
  return math.random(a, b);
end

-- trying to locate position for particles by player look direction for performance reason.
-- it is costly to generate many particles around player so goal is focus mainly on front view.  
function get_random_pos_by_player_look_dir(player)
  local look_dir = player:get_look_dir()
  local player_pos = player:getpos()

  local random_pos_x = 0
  local random_pos_y = 0
  local random_pos_z = 0

  if look_dir.x > 0 then
    if look_dir.z > 0 then
      random_pos_x = math.random() + math.random(player_pos.x - 2.5, player_pos.x + 10)
      random_pos_z = math.random() + math.random(player_pos.z - 2.5, player_pos.z + 10)
    else
      random_pos_x = math.random() + math.random(player_pos.x - 2.5, player_pos.x + 10)
      random_pos_z = math.random() + math.random(player_pos.z - 10, player_pos.z + 2.5)
    end
  else
    if look_dir.z > 0 then
      random_pos_x = math.random() + math.random(player_pos.x - 10, player_pos.x + 2.5)
      random_pos_z = math.random() + math.random(player_pos.z - 2.5, player_pos.z + 10)
    else
      random_pos_x = math.random() + math.random(player_pos.x - 10, player_pos.x + 2.5)
      random_pos_z = math.random() + math.random(player_pos.z - 10, player_pos.z + 2.5)
    end
  end

  random_pos_y = math.random() + random_pos(player_pos.y + 1, player_pos.y + 7)
  return random_pos_x, random_pos_y, random_pos_z
end

minetest.register_globalstep(function(dtime)
  -- recalculate weather only when there aren't currently any
  if (weather.state ~= "none") then
    if (weather.end_time ~= nil and weather.end_time <= os.time()) then
      weather.known_weathers[weather.state].clear()
      weather.state = "none"
    end
  end
  
  if (weather.next_check <= os.time()) then
    for reg_weather_name, reg_weather_obj in pairs(weather.known_weathers) do 
      if (reg_weather_obj ~= nil and reg_weather_obj.chance ~= nil) then
        local random_roll = math.random(0,100)
        if (random_roll <= reg_weather_obj.chance) then
          weather.state = reg_weather_name
          weather.end_time = weather.get_rand_end_time()
        end
      end
    end
    weather.next_check = os.time() + weather.check_interval
  end
end)

minetest.register_privilege("weather_manager", {
  description = "Gives ability to control weather",
  give_to_singleplayer = false
})

-- Weather command definition. Set 
minetest.register_chatcommand("set_weather", {
  params = "<weather>",
  description = "Changes weather by given param, parameter none will remove weather.",
  privs = {rain_manager = true},
  func = function(name, param)
    if (param == "none") then
      if (weather.state ~= nil and weather.known_weathers[weather.state] ~= nil) then
        weather.known_weathers[weather.state].clear()
        weather.state = param
      end
      weather.state = "none"
    end
  
    if (weather.known_weathers ~= nil and weather.known_weathers[param] ~= nil) then
      if (weather.state ~= nil and weather.state ~= "none" and weather.known_weathers[weather.state] ~= nil) then
        weather.known_weathers[weather.state].clear()
      end
      weather.state = param
    end
  end
})

-- Overrides nodes 'sunlight_propagates' attribute for efficient indoor check (e.g. for glass roof).
-- Controlled from minetest.conf setting and by default it is disabled.
-- To enable set weather_allow_override_nodes to true. 
-- Only new nodes will be effected (glass roof needs to be rebuilded).
if minetest.setting_getbool("weather_allow_override_nodes") then
  if minetest.registered_nodes["default:glass"] then
    minetest.override_item("default:glass", {sunlight_propagates = false})
  end
  if minetest.registered_nodes["default:meselamp"] then
    minetest.override_item("default:meselamp", {sunlight_propagates = false})
  end
end