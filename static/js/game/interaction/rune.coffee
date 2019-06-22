window.Brew.Interaction.Rune =
	use: (user, rune_item) ->

		if rune_item.itemType == Brew.ItemType.type_of.rune.health.id
			runeHealth(rune_item)

		else if rune_item.itemType == Brew.ItemType.type_of.rune.portal.id
			runePortal(rune_item)

		else if rune_item.itemType == Brew.ItemType.type_of.rune.recall.id
			runeRecall(rune_item)

		else if rune_item.itemType == Brew.ItemType.type_of.rune.lightning.id
			runeLightning(rune_item)

		else
			console.error("unexpected rune item", rune_item)

		# identify this item
		new_id = Brew.Catalog.identify(rune_item)

		return true

runeRecall = (rune) ->
	Brew.Axe.doRecallAxe(rune)
	
runeHealth = (rune) ->
	player = Brew.gamePlayer()
	level = Brew.gameLevel()

	# add health
	player.getStat(Brew.stat.health).addTo(1)
	Brew.Display.drawHudAll()

	level.removeItemAt(rune.coordinates)

	Brew.Game.endPlayerTurn()
		
runeLightning = (rune) ->
	player = Brew.gamePlayer()
	level = Brew.gameLevel()

	# remove any similar 'towards enemy' flags?
	player.setFlag(Brew.flags.conjure_lightning.id)
	player.createStat(Brew.stat.ammo, Brew.config.lightning_ammo_per_rune)

	Brew.msg("Bzzt!")
	Brew.Display.drawHudAll()
	level.removeItemAt(rune.coordinates)
	Brew.Game.endPlayerTurn()

runePortal = (rune) ->
	player = Brew.gamePlayer()
	level = Brew.gameLevel()

	# # add health
	# player.getStat(Brew.stat.health).addTo(1)
	# Brew.Display.drawHudAll()

	old_xy = player.coordinates
	teleport_xy = rune.pair_xy

	monster_at = level.getMonsterAt(teleport_xy)
	if monster_at?
		if monster_at.hasFlag(Brew.flags.cant_telefrag.id)
			Brew.msg("Blocked!")
		else
			Brew.Combat.killMonster(player, monster_at, false)

	level.removeMonsterAt(old_xy)
	level.setMonsterAt(teleport_xy, player)

	Brew.Display.drawMapAt(old_xy)
	Brew.Display.drawMapAt(teleport_xy)

	Brew.Sounds.play("portal")
	Brew.Game.endPlayerTurn()