# targeting lookups
# targeting definition
#	range: integer
#	blockedByTerrain: true/false
#	blockedByOtherTargets: true/false

window.Brew.Targeting =
	getPotentialTargets: (shooter, given_target_def) ->
		# return a list of valid targets for a shooter/caster and a given set of criteria

		# construct target definition using defaults if necessary
		target_def = getTargetDefinitionWithDefaults(given_target_def)

		if target_def.target_player
			# todo: include player allies
			enemies_in_view = (m for m in Brew.gameLevel().getMonsters() when shooter.hasKnowledgeOf(m) and Brew.utils.compareThing(m, Brew.gamePlayer()))
		else
			enemies_in_view = (m for m in Brew.gameLevel().getMonsters() when shooter.hasKnowledgeOf(m) and not Brew.utils.compareThing(m, Brew.gamePlayer()))

		potential_targets = []
		for m in enemies_in_view
			[is_ok, err_msg, traverse_lst] = Brew.Targeting.checkGenericRangedAttack(
				shooter.coordinates, 
				m.coordinates,
				target_def # pass this on to range checker
			)
			if is_ok
				potential_targets.push(m)

		return potential_targets

	checkSimpleRangedAttack: (attacker, target) ->
		# returns true if an attacker can hit a given target

		# can't shoot if you don't know it is there
		if not attacker.hasKnowledgeOf(target)
			return [false, Brew.errors.ATTACK_NOT_KNOWN, []]

		# can't shoot what you can't see (should be same as above)
		if not attacker.canView(target.coordinates)
			return [false, Brew.errors.ATTACK_NOT_VISIBLE, []]

		[is_ok, err_msg, traverse_lst] = Brew.Targeting.checkGenericRangedAttack(
			attacker.coordinates, 
			target.coordinates,
			{
				range: attacker.getAttackRange(),
				blockedByTerrain: true,
				blockedByOtherTargets: true
			}
		)
		console.log(attacker, err_msg)
		return [is_ok, err_msg, traverse_lst]

	showTargeting_Throw: (item) ->
		Brew.Menu.popup.context = "target"
		Brew.Menu.popup.target_context = "throw"
		Brew.Menu.popup.item = item
		Brew.Menu.popup.target_def = {
			range: 10 # todo: what is range of throwing?
			blockedByTerrain: true
			blockedByOtherTargets: true
			requiresTarget: false
		}

		Brew.Targeting.showTargeting()

	# showTargeting_Ability: () ->
		# blah blah
		# blockedByOtherTargets: if @popup.ability? then Brew.ability[@popup.ability].pathing else true,

	showTargeting: () ->
		Brew.Display.clearDialogDisplay()
		Brew.Display.drawDisplayAll()

		# shortcut
		target_def = getTargetDefinitionWithDefaults(Brew.Menu.popup.target_def)
		
		# find potential targets
		Brew.Menu.popup.targets = Brew.Targeting.getPotentialTargets(Brew.gamePlayer(), target_def)

		if Brew.Menu.popup.targets.length == 0 and target_def.requiresTarget
			# TODO: move appendBlanksToString to utils
			# Brew.Display.drawTextOnPanel("footer", 0, 0, Brew.Display.appendBlanksToString("No targets in range", Brew.panels.footer.width))
			Brew.msg("No targets")
			# @drawRangeOverlay(@gamePlayer().coordinates, range, Brew.colors.yellow)
			Brew.Input.setInputHandler("popup_to_dismiss")

		else if Brew.Menu.popup.targets.length == 0 and (not target_def.requiresTarget)
			first_xy = Brew.gamePlayer().coordinates
			Brew.Targeting.updateAndDrawTargeting(first_xy)
			Brew.Input.setInputHandler("targeting")

		else
			Brew.Menu.popup.target_index = 0
			first_target = Brew.Menu.popup.targets[0]

			Brew.Targeting.updateAndDrawTargeting(first_target.coordinates)
			# Brew.Display.drawTextOnPanel("footer", 0, 0, Brew.Display.appendBlanksToString("Targeting blahblah", Brew.panels.footer.width))
			Brew.Input.setInputHandler("targeting")

	updateAndDrawTargeting: (target_xy) ->
		# clear old line if any
		old_line = Brew.Menu.popup.line ? []

		for xy in old_line
			Brew.Display.clearHighlightAt(xy)
			Brew.Display.drawMapAt(xy)

		is_ok = true
		line = []
		# sometimes the "line" is just the player, by default
		if Brew.gamePlayer().coordinates.compare(target_xy)
			line = [Brew.gamePlayer().coordinates]

		else
			[is_ok, err_msg, traverse_lst] = Brew.Targeting.checkGenericRangedAttack(Brew.gamePlayer().coordinates, target_xy, Brew.Menu.popup.target_def)

			if is_ok
				line = traverse_lst

			else if err_msg in [Brew.errors.ATTACK_BLOCKED_TERRAIN, Brew.errors.ATTACK_BLOCKED_MONSTER]
				last_good_xy = traverse_lst[0]
				if last_good_xy?
					line = Brew.utils.getLineBetweenPoints(Brew.gamePlayer().coordinates, last_good_xy)
					
					if line.length > 1
						# remove player from front of line if cursor is not on player
						line = line[1..line.length-1]

				# show target 'cursor' at the end when blocked, so user knows where they are
				line.push(target_xy)

			else if err_msg == Brew.errors.ATTACK_OUT_OF_RANGE
				# show target 'cursor' at the end when out of range, so user knows where they are
				line = [target_xy]

			else 
				console.error("unhandled targeting error #{err_msg}")

		for xy in line
			highlight_color = if is_ok then Brew.colors.yellow else Brew.colors.red
			Brew.Display.setHighlightAt(xy, highlight_color)
			Brew.Display.drawMapAt(xy)

		Brew.Menu.popup.line = line
		Brew.Menu.popup.xy = target_xy
		Brew.Menu.popup.is_ok = is_ok
		Brew.Menu.popup.err_msg = err_msg
		# Brew.Menu.popup.traverse_lst = traverse_lst

	# drawRangeOverlay: (center_xy, range, color) ->
	# 	# draw a circle on the dialog display

	# 	start_x = center_xy.x - range
	# 	start_y = center_xy.y - range
		
	# 	@setDialogDisplayTransparency(0.5)

	# 	for x in [start_x..start_x+range*2]
	# 		for y in [start_y..start_y+range*2]
				
	# 			dist = Brew.utils.dist2d_xy(center_xy.x, center_xy.y, x, y)
				
	# 			if dist <= range
	# 				xy = new Coordinate(x, y)
	# 				t = Brew.gameLevel().getTerrainAt(xy)
	# 				if t? and Brew.gamePlayer().canView(xy)
	# 					my_dialog_display.draw(Brew.panels.game.x + x, Brew.panels.game.y + y, " ", null, ROT.Color.toHex(color))


	checkGenericRangedAttack: (start_xy, target_xy, target_def) ->
		# too far away?
		dist = Brew.utils.dist2d(start_xy, target_xy)

		if dist > target_def.range
			return [false, Brew.errors.ATTACK_OUT_OF_RANGE, []]

		# make sure nothing is in the way
		full_traverse_lst = Brew.utils.getLineBetweenPoints(start_xy, target_xy)
		
		# ignore first and last points
		if full_traverse_lst.length < 2
			throw "Traversal path should never be less than 2"
		else
			len = full_traverse_lst.length
			traverse_lst = full_traverse_lst[1..len-1]

		# make sure there aren't any other monsters in the way
		last_xy = null
		for xy, i in traverse_lst
			t = Brew.gameLevel().getTerrainAt(xy)
			if t.blocks_walking and target_def.blockedByTerrain
				return [false, Brew.errors.ATTACK_BLOCKED_TERRAIN, [last_xy]]

			# special case for final spot ("target") since it could be a monster
			if i == (traverse_lst.length - 1) and not target_def.blockedByAnyTarget
				continue

			m = Brew.gameLevel().getMonsterAt(xy)
			if m? and target_def.blockedByOtherTargets
				return [false, Brew.errors.ATTACK_BLOCKED_MONSTER, [last_xy]]

			last_xy = xy

		return [true, "OK", traverse_lst]


getTargetDefinitionWithDefaults = (given_target_def) ->
	# range is required, at a minimum
	if not given_target_def.range?
		console.error("need at least range in target definition")

	return {
		range: given_target_def.range
		blockedByTerrain: given_target_def.blockedByTerrain ? true
		blockedByOtherTargets: given_target_def.blockedByOtherTargets ? true
		target_player: given_target_def.target_player ? false
		requiresTarget: given_target_def.requiresTarget ? true
		blockedByAnyTarget: given_target_def.blockedByAnyTarget ? false
	}
