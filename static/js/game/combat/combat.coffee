Brew.Combat =
	# constructor: (@game) ->
	# 	@ui = @game.ui
	# 	true

	attack: (attacker, defender, is_melee, options) ->
		options ?= {}
		# console.log(attacker, defender, is_melee, options)
		defender.last_attacked = Brew.Game.turn

		attacker_is_player = attacker.group == "player"
		
		if not defender?
			debugger
		defender_is_player = defender.group == "player"

		combat_msg = ""
		if attacker_is_player
			combat_msg += "You "
			combat_msg += if is_melee then "punch " else "fire at "
			combat_msg += "the " + defender.name
		else
			combat_msg += "The " + attacker.name + " "
			combat_msg += if is_melee then "attacks " else "shoots at "
			combat_msg += if defender_is_player then "you" else "the " + defender.name

		if defender.hasFlag(Brew.flags.is_shielded.id)
			flash_color = Brew.colors.green
			damage = 0
			defender.removeFlag(Brew.flags.is_shielded.id)

		else
			flash_color = Brew.colors.red
		
			# figure out DAMAGE
			if attacker_is_player and options.remote?
				# player-initiated remote attack
				damage = options.remote.damage

				# override recall axe damage (set to distance traveled)
				if options.recall_damage?
					damage = options.recall_damage

				defender.getStat(Brew.stat.health).deductOverflow(damage)

				# Brew.msg("Your #{options.remote.name} attacks #{defender.name}")

			else if attacker_is_player
				# WEAPON - figure out which weapon we are using
				equipped_wpn = attacker.inventory?.getEquipped(Brew.equip_slot.melee)
				
				
				if equipped_wpn?
					# if we have an axe, +stamina damage, minimum damage is (1) or axe damage level
					damage = Math.max(attacker.getStat(Brew.stat.stamina).getCurrent(), equipped_wpn.damage)
				
				else
					# no axe - just do base damage (1)
					damage = attacker.getAttackDamage(is_melee)

				# console.log("Did #{damage} damage")

				# give back 'extra' stamina so we don't waste it
				overkill = defender.getStat(Brew.stat.health).deductOverflow(damage)		
				if overkill > 0
					attacker.getStat(Brew.stat.stamina).addTo(overkill)
					# console.log("Adding back #{overkill} stamina")

				# Brew.msg(combat_msg)

			# non-player attacker
			else
				damage = attacker.getAttackDamage(is_melee)
				defender.getStat(Brew.stat.health).deductOverflow(damage)		

				# Brew.msg(combat_msg)

		

		damage_color = if defender_is_player then Brew.colors.red else Brew.colors.light_blue
		Brew.Game.addAnimation(new Brew.FlashEffect(defender.coordinates, damage_color))
		Brew.Display.showFloatingTextAbove(defender.coordinates, "#{damage}", damage_color)

		# remove flags when hit
		# if damage > 0 and defender.hasFlag(Brew.flags.is_stunned.id)
		
		## check for death -- ouch
		is_dead = defender.getStat(Brew.stat.health).isZero()
		
		Brew.Display.drawHudAll()

		defender_is_player = defender.group == "player"

		if is_dead and defender_is_player
			Brew.Game.gameOver(attacker, defender, is_melee, overkill)
		else if is_dead
			Brew.Combat.killMonster(attacker, defender, is_melee, overkill)
			

		true

	killMonster: (attacker, victim, is_melee, overkill_damage) ->
		dead_xy = clone(victim.coordinates)

		# Brew.msg("You kill the " + victim.name)
		victim.is_dead = true
		if victim.light_source?
			console.log("victim was a light source")
			lights = Brew.gameLevel().updateLightMap()
			Brew.Display.drawMapAtList(lights)
		
		Brew.gameLevel().removeMonsterAt(victim.coordinates)
		Brew.Game.scheduler.remove(victim)
		Brew.Display.drawMapAt(dead_xy)
		
		Brew.Axe.updateOnKill(victim, is_melee, overkill_damage)
		
		if victim.hasFlag(Brew.flags.explodes_on_death.id)
			explode_xy = clone(victim.coordinates)
			Brew.Axe.explodeOnDeath(victim, explode_xy)

		if victim.hasFlag(Brew.flags.respawns_on_death.id)
			Brew.Axe.respawnOnDeath(victim)

		if victim.def_id == "BOSS_MONSTER"
			Brew.Game.doVictory()
