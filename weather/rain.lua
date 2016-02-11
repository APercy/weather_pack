-- Rain

function getRandomRange(offset, range)
  if range < 0 then
    return offset + math.random() + math.random(range, 0)
  elseif range > 0 then
    return offset + math.random() + math.random(0, range)
  else
    return 0
  end
end

rain = {}

rain.add_short_range_particlespawner = function (player)
  local ppos = player:getpos()
  local short_range_pos_min = {}
  short_range_pos_min.x = getRandomRange(ppos.x, -3)
  short_range_pos_min.y = ppos.y + 3
  short_range_pos_min.z = getRandomRange(ppos.z, -3)

  if minetest.get_node_light(short_range_pos_min, 0.5) ~= 15 then
    return false
  end

  local short_range_pos_max = {}
  short_range_pos_max.x = getRandomRange(ppos.x, 3)
  short_range_pos_max.y = ppos.y + 3
  short_range_pos_max.z = getRandomRange(ppos.z, 3)

  if minetest.get_node_light(short_range_pos_max, 0.5) ~= 15 then
    return false
  end

  minetest.add_particlespawner({
    amount=15,
    time=0.3,
    minpos=short_range_pos_min,
    maxpos=short_range_pos_max,
    minvel={x=0, y=-20, z=0},
    maxvel={x=0.2, y=-20, z=0.2},
    minacc={x=0, y=-10, z=0},
    maxacc={x=0.2, y=-10, z=0.2},
    minexptime=0.2,
    maxexptime=0.3,
    minsize=0.5,
    maxsize=2,
    collisiondetection=true,
    vertical=true,
    texture="weather_raindrop.png",
    player=player:get_player_name()})

  return true

end

rain.add_long_range_particlespawner = function (player)
  local ppos = player:getpos()
  local long_range_pos_min = {}
  long_range_pos_min.x = getRandomRange(ppos.x, -20)
  long_range_pos_min.y = ppos.y + 10
  long_range_pos_min.z = getRandomRange(ppos.z, -20)

  if minetest.get_node_light(long_range_pos_min, 0.5) ~= 15 then
    return false
  end

  local long_range_pos_max = {}
  long_range_pos_max.x = getRandomRange(ppos.x, 20)
  long_range_pos_max.y = ppos.y + 10
  long_range_pos_max.z = getRandomRange(ppos.z, 20)

  if minetest.get_node_light(long_range_pos_max, 0.5) ~= 15 then
    return false
  end

  minetest.add_particlespawner({
    amount=40,
    time=0.5,
    minpos=long_range_pos_min,
    maxpos=long_range_pos_max,
    minvel={x=0, y=-20, z=0},
    maxvel={x=0.2, y=-20, z=0.2},
    minacc={x=0, y=-20, z=0},
    maxacc={x=0.2, y=-20, z=0.2},
    minexptime=0.2,
    maxexptime=0.5,
    minsize=0.5,
    maxsize=2,
    collisiondetection=true,
    vertical=true,
    texture="weather_raindrop.png",
    player=player:get_player_name()})
    
  return true
end

minetest.register_on_joinplayer(function(player)

end)

minetest.register_globalstep(function(dtime)
  if weather.state ~= "rain" then return end
  for _, player in ipairs(minetest.get_connected_players()) do
    local ppos = player:getpos()

    local rain_nearby = rain.add_short_range_particlespawner(player)
    local rain_distant = rain.add_long_range_particlespawner(player)
    
    if rain_nearby or rain_distant then
      if weather.players[player:get_player_name()] == nil then
        local player_name = player:get_player_name()
        local player_info = {}
        player_info.sound_handler = minetest.sound_play("weather_rain", {
          object = player,
          max_hear_distance = 2,
          loop = true,
        })
        player_info.sky_box = {player:get_sky()}
        if (minetest.get_timeofday() < 0.8) then
          player:set_sky({r=65, g=80, b=100}, "plain", nil)
        else
          player:set_sky({r=10, g=10, b=15}, "plain", nil)
        end
        weather.players[player_name] = player_info
      end
    end
  end
end)



