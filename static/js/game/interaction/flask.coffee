window.Brew.Interaction.Flask =
	use: (user, flask) ->
		## TODO: can monsters use items? if so change this text
		Brew.msg("You open #{Brew.Catalog.getItemName(flask)}...")
		
		user.inventory.removeItemByKey(flask.inv_key)

		if flask.itemType == Brew.ItemType.type_of.flask.fire.id
			Brew.Game.setFlagWithCounter(user, Brew.flags.on_fire, 5)
			Brew.msg("You are on fire!")
			Brew.Display.drawMapAt(user.coordinates)

		else if flask.itemType == Brew.ItemType.type_of.flask.health.id
			Brew.msg("Your health improves!")
			user.getStat(Brew.stat.health).addToMax(1)
			user.getStat(Brew.stat.health).reset()

			Brew.Display.drawHudAll()

		else if flask.itemType == Brew.ItemType.type_of.flask.weakness.id
			Brew.msg("A wave of weakness overwhelms you")
			user.getStat(Brew.stat.stamina).setTo(0)
			Brew.Display.drawHudAll()

		else if flask.itemType == Brew.ItemType.type_of.flask.might.id
			Brew.Game.setFlagWithCounter(user, Brew.flags.is_mighty, 20)
			Brew.msg("Supernatural strength flows through you")
			Brew.Display.drawMapAt(user.coordinates)

		else if flask.itemType == Brew.ItemType.type_of.flask.invisible.id
			Brew.Game.setFlagWithCounter(user, Brew.flags.invisible, 10)
			Brew.msg("You can see right through yourself!")
			Brew.Display.drawMapAt(user.coordinates)

		else if flask.itemType == Brew.ItemType.type_of.flask.vigor.id
			Brew.msg("This makes you feel amazing!")
			user.getStat(Brew.stat.stamina).addToMax(1)
			user.getStat(Brew.stat.stamina).reset()
			Brew.Display.drawHudAll()

		else
			console.error("unexpected flask item", flask)

		# identify this item
		new_id = Brew.Catalog.identify(flask)
		# if new_id
		# 	Brew.msg("Now you know...")

		return true
