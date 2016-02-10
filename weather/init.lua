-- Weather:
-- * rain
-- * snow

assert(minetest.add_particlespawner, "Your Minetest version is incompatible with this mod")

weather = {
  state = "none",
  players = {},
}

weather.remove_weather = function (player_name)
    local player_info = weather.players[player_name]
    minetest.sound_stop(player_info.sound_handler)
    local p = minetest.get_player_by_name(player_name)
    if p ~= nil then
      p:set_sky(player_info.sky_box[1], player_info.sky_box[2], player_info.sky_box[3])
    end
end

save_weather = function ()
  for player_name, player_info in pairs(weather.players) do
    if player_info ~= nil then
      weather.remove_weather(player_name)
    end
  end
  weather.players = {}
  local file = io.open(minetest.get_worldpath().."/weather", "w+")
  file:write(weather.state)
  file:close()
end

read_weather = function ()
  local file = io.open(minetest.get_worldpath().."/weather", "r")
  if not file then return end
  local readweather = file:read()
  file:close()
  return readweather
end

weather.state = read_weather()

minetest.register_globalstep(function(dtime)
  if weather.state == "rain" or weather.state == "snow" then
    if math.random(1, 10000) == 1 then
      weather.state = "none"
      save_weather()
    end
  else
    if math.random(1, 50000) == 1 then
      weather.state = "rain"
      save_weather()
    end
    if math.random(1, 50000) == 2 then
      weather.state = "snow"
      save_weather()
    end
  end
end)

dofile(minetest.get_modpath("weather").."/rain.lua")
dofile(minetest.get_modpath("weather").."/snow.lua")
dofile(minetest.get_modpath("weather").."/command.lua")


