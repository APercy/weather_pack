

minetest.register_chatcommand("cw", {
  description = "normalize weather",
  privs = {rain_manager = true},
  func = function(name, param)
    weather.state = 'clear'
    save_weather()
  end
})