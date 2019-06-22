window.Brew.Debug =
	# ------------------------------------------------------------
	# DEBUG
	# ------------------------------------------------------------
	debugMonsterFov: () ->
		# cycle through monster FOV

		# here are all our monsters
		monsters = @gameLevel().getMonsters()
		fov_monster = null

		if monsters.length == 0
			console.log("No monsters on the level")

		if not @debug.fov.monster?
			# if we arent already showing one, pick the first
			@debug.fov.monster = monsters[0]

		else
			indices = (m.id for m in monsters)
			current_idx = indices.indexOf(@debug.fov.monster.id)
			new_idx = current_idx + 1
			if new_idx > monsters.length
				# all done cycling
				@debug.fov = {}

			else
				@debug.fov.monster = monsters[new_idx]

		@drawDisplayAll()

	pathmaps: {}
	
	debugPathMaps: () ->
		# cycle through monster pathmaps
		# press q first time = initialize list, index pointer
		# press q next time = cycle through list
		# get to start of list again = quit

		if not Brew.Debug.pathmaps.list?
			# create a list of all pathmaps
			Brew.Debug.pathmaps.list = []
			Brew.Debug.pathmaps.index = -1

			# here are all our monsters
			for monster in Brew.gameLevel().getMonsters()
				for own key, pathmap of monster.pathmaps
					title = "#{ monster.name } #{ monster.id } #{ key }"
					Brew.Debug.pathmaps.list.push([title, pathmap])

			# generic game pathmaps
			for own key, pathmap of Brew.Game.pathmaps
				title = "game #{ key }"
				Brew.Debug.pathmaps.list.push([title, pathmap])

		# clear the screen first i guess
		arg = Brew.Debug.pathmaps.index
		delete Brew.Debug.pathmaps["index"]
		Brew.Display.drawDisplayAll()

		Brew.Debug.pathmaps.index = arg

		# we have a list, increment and display it
		Brew.Debug.pathmaps.index += 1
		if Brew.Debug.pathmaps.index == Brew.Debug.pathmaps.list.length
			# turn it off
			Brew.Debug.pathmaps = {}
		else
			console.log("showing pathmap: " + Brew.Debug.pathmaps.list[Brew.Debug.pathmaps.index][0])

		Brew.Display.drawDisplayAll()

	# debugUpdatePairDisplay: () ->
	# 	@game.socket.requestDisplayUpdate()

	debugAtCoords: () ->
		grid_obj_xy = grid_manager.getLastVisitGrid()
		grid_xy = new Coordinate(grid_obj_xy.x, grid_obj_xy.y)

		if Brew.Display.getPanelAt(grid_xy) != "game"
			return

		map_xy = Brew.Display.screenToMap(grid_xy)

		console.log("grid xy", grid_obj_xy)
		console.log("map xy", map_xy)
		key = map_xy.toKey()
		console.log("key", key)
		
		console.log("terrain", Brew.gameLevel().getTerrainAt(map_xy))
		
		f = Brew.gameLevel().getFeatureAt(map_xy)
		console.log("feature", if f? then f else "none")

		i = Brew.gameLevel().getItemAt(map_xy)
		console.log("item", if i? then i else "none")

		m = Brew.gameLevel().getMonsterAt(map_xy)
		console.log("monster", if m? then m else "none")

		o = Brew.gameLevel().getOverheadAt(map_xy)
		console.log("overhead", if o? then o else "none")

		mem = Brew.gamePlayer().getMemoryAt(Brew.gameLevel().id, map_xy)
		console.log("memory", if mem? then mem else "none")

		console.log("can_view", Brew.gamePlayer().canView(map_xy))
		console.log("light", Brew.gameLevel().getLightAt(map_xy))
		console.log("light (NoA)", Brew.gameLevel().getLightAt_NoAmbient(map_xy))

		# pathmaps
		# here are all our monsters
		for monster in Brew.gameLevel().getMonsters()
			for own key, pathmap of monster.pathmaps
				title = "#{ monster.name } #{ monster.id } #{ key }"
				# debug_pathmaps_list.push([title, pathmap])
				console.log("pathmap #{title}:", pathmap[map_xy.toKey()])


		# generic game pathmaps
		for own key, pathmap of Brew.Game.pathmaps
			title = "game #{ key }"
			# debug_pathmaps_list.push([title, pathmap])
			console.log("pathmap #{title}:", pathmap[map_xy.toKey()])



		true