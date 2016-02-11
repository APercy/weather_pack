-- Snow

minetest.register_globalstep(function(dtime)
  if weather.state ~= "snow" then return end
  for _, player in ipairs(minetest.get_connected_players()) do
    local ppos = player:getpos()
    local offset = player:get_eye_offset()
    local player_eye_pos = {x = ppos.x + offset.x, y = ppos.y+offset.y + 1.5, z = ppos.z+offset.z}

    if minetest.get_node_level(player_eye_pos) == 8 then
      return false
    end

    add_long_range_particlespawner(player)
  end
end)

function add_long_range_particlespawner(player)
  local ppos = player:getpos()
  local long_range_pos_min = {}
  long_range_pos_min.x = getRandomRange(ppos.x, -20)
  long_range_pos_min.y = ppos.y + 10
  long_range_pos_min.z = getRandomRange(ppos.z, -20)

  if minetest.get_node_light(long_range_pos_min, 0.5) ~= 15 then return end

  local long_range_pos_max = {}
  long_range_pos_max.x = getRandomRange(ppos.x, 20)
  long_range_pos_max.y = ppos.y + 10
  long_range_pos_max.z = getRandomRange(ppos.z, 20)

  if minetest.get_node_light(long_range_pos_max, 0.5) ~= 15 then return end

  local random_texture = nil
  if math.random() > 0.5 then
    random_texture = "weather_snowflake1.png"
  else
    random_texture = "weather_snowflake2.png"
  end

  minetest.add_particlespawner({
    amount=30,
    time=1.5,
    minpos=long_range_pos_min,
    maxpos=long_range_pos_max,
    minvel={x=-1, y=-2, z=-1},
    maxvel={x=1, y=-7, z=1},
    minacc={x=-1, y=-2, z=-1},
    maxacc={x=1, y=-0.3, z=1},
    minexptime=0.5,
    maxexptime=1.5,
    minsize=0.5,
    maxsize=3,
    collisiondetection=true,
    vertical=false,
    texture=random_texture,
    player=player:get_player_name()})
end


