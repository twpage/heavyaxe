window.Brew = 
	Game: null

	msg: (text) ->
		Brew.Game.msg(text)

	gameLevel: () ->
		return Brew.Game.my_level

	gamePlayer: () ->
		return Brew.Game.my_player

	Interaction: {}
	