window.Brew.Interaction.Scroll =
	use: (user, scroll) ->
		# Brew.msg("You read #{Brew.Catalog.getItemName(scroll)}...")
		
		user.inventory.removeItemByKey(scroll.inv_key)

		if scroll.itemType == Brew.ItemType.type_of.scroll.recall.id
			scrollRecall(scroll)

		else if scroll.itemType == Brew.ItemType.type_of.scroll.sacrifice.id
			scrollSacrifice(scroll)

		else if scroll.itemType == Brew.ItemType.type_of.scroll.teleport.id
			scrollTeleport(scroll)

		else if scroll.itemType == Brew.ItemType.type_of.scroll.shield.id
			scrollShield(scroll)

		else if scroll.itemType == Brew.ItemType.type_of.scroll.shatter.id
			scrollShatter(scroll)

		else
			console.error("unexpected scroll item", scroll)

		# identify this item
		new_id = Brew.Catalog.identify(scroll)
		if new_id
			Brew.Display.drawDisplayAll()
			Brew.msg("#{Brew.Catalog.getItemName(scroll)}")
			# Brew.msg("Now you know...")

		return true

scrollShatter = (scroll) ->
	player = Brew.gamePlayer()
	level = Brew.gameLevel()

	smashed_anything = false
	for neighbor_xy in player.coordinates.getAdjacent()
		if not level.checkValid(neighbor_xy)
			continue

		t = level.getTerrainAt(neighbor_xy)
		if t.blocks_walking
			# smash it!
			level.setTerrainAt(neighbor_xy, Brew.terrainFactory("FLOOR"))
			Brew.Display.drawMapAt(neighbor_xy)
			smashed_anything = true

	if smashed_anything
		level.calcTerrainNavigation()

	Brew.msg("Kersmash")
	# Brew.Game.endPlayerTurn() # shatter doesnt end turn

scrollShield = (scroll) ->
	player = Brew.gamePlayer()
	player.setFlag(Brew.flags.is_shielded.id)
	Brew.Display.drawMapAt(player.coordinates)
	Brew.Display.drawHudAll()
	# Brew.Game.endPlayerTurn() # shield doesnt end turn

scrollTeleport = (scroll) ->
	# try to teleport the player somewhere safe-ish?

	player = Brew.gamePlayer()
	level = Brew.gameLevel()

	teleport_xy = Brew.Axe.findSafeLevelCoordinates(3)
	old_xy = player.coordinates

	level.removeMonsterAt(old_xy)
	level.setMonsterAt(teleport_xy, player)
	Brew.Display.drawMapAt(old_xy)
	Brew.Display.drawMapAt(teleport_xy)

	Brew.Sounds.play("portal")
	Brew.Game.endPlayerTurn()

scrollRecall = (scroll) ->
	Brew.Axe.doRecallAxe(scroll)



scrollSacrifice = (scroll) ->
	player = Brew.gamePlayer()

	# always reset stamina to max
	player.getStat(Brew.stat.stamina).reset()

	# increment  DOOM
	player.getStat(Brew.stat.doom).addTo(Brew.config.sacrifice_cost)
	Brew.Game.addAnimation(new Brew.ShinyEffect(player.coordinates, Brew.colors.stamina))

	Brew.Display.drawHudAll()
	# Brew.Game.endPlayerTurn() # sacrifice doesnt end turn
	Brew.Game.runAnimationsOnly(true)


