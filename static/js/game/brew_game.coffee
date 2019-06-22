class window.Brew.GameObject
	constructor: (display_info) ->
		@levels = {}
		@pathmaps = {}
		
		@my_level = null
		@my_player = null
		
		@ai = null
		# @combat = null
		@dummy_fov = null

		@animations = []
		@scheduler = new ROT.Scheduler.Speed()
		# @ui = new Brew.UserInterface(@, display_info)
		Brew.Display.init(display_info)

		@item_catalog = {}
		@turn = 0
		@debugDropdownMenu()

	# send all keypresses to the user_interface class
	keypress: (e) -> 
		@ui.keypress(e)

	start: (player_name, hero_type) ->
		given_seed = getParameterByName("seed")
		console.log(given_seed)
		if given_seed?
			@seed = Number(given_seed)
			console.log(given_seed)

		else
			@seed = Math.floor(ROT.RNG.getUniform() * 999999999)

		console.log(@seed)
		ROT.RNG.setSeed(@seed)
		@my_player = @createPlayer(hero_type)
		@my_player.name = player_name

		@ai = new Brew.MonsterAI(@)
		# @combat = new Brew.Combat(@)
		# randomize our items
		Brew.Catalog.randomizeItemCatalog()

		# build the first level
		id = @createLevel(0)
		@setCurrentLevel(id)
		$("#id_div_seed").html("<p><span style='color: grey'><a href='/index.html?seed=#{@seed}'>[ Replay or Copy this Seed #{@seed} ]</a></span></p>")
		true

	restart: () ->
		@seed = Math.floor(ROT.RNG.getUniform() * 999999999)

		ROT.RNG.setSeed(@seed)
		@my_player = @createPlayer(@my_player.hero_type ? null)
		@my_player.name = player_name

		@ai = new Brew.MonsterAI(@)
		# @combat = new Brew.Combat(@)
		# randomize our items
		Brew.Catalog.randomizeItemCatalog()

		# build the first level
		id = @createLevel(0)
		@setCurrentLevel(id)
		$("#id_div_seed").html("<p><span style='color: grey'><a href='/index.html?seed=#{@seed}'>[ Replay or Copy this Seed #{@seed} ]</a></span></p>")
		true

	createPlayer: () ->
		player = Brew.monsterFactory("PLAYER")
		player.createStat(Brew.stat.health, 3)
		player.createStat(Brew.stat.stamina, 6)
		player.createStat(Brew.stat.doom, Brew.config.initial_doom_level)
		
		player.setFlag(Brew.flags.see_all.id)

		heavy_axe = Brew.itemFactory("WPN_AXE")
		player.inventory.addItem(heavy_axe, "0")
		player.inventory.equipItem(heavy_axe, Brew.equip_slot.melee)

		player.inventory.addItem(Brew.itemFactory("SCROLL_RECALL"))

		starting_scrolls = ["SCROLL_SHATTER", "SCROLL_RECALL", "SCROLL_RECALL", "SCROLL_TELEPORT"]
		for i in [1..Brew.config.starting_scrolls]
			random_scroll = starting_scrolls.random()
			player.inventory.addItem(Brew.itemFactory(random_scroll))
		
		# player.inventory.addItem(Brew.itemFactory("SCROLL_SACRIFICE"))


		return player
		
	refreshScheduler: () ->
		# clear and rebuild the scheduler
		@scheduler.clear()
		for mob in @my_level.getMonsters()
			@scheduler.add(mob, true)

		# @endPlayerTurn()

	updatePathMapsFor: (monster, calc_from) ->
		calc_from ?= false # assume we aren't running away
		monster.pathmaps[Brew.paths.to_player] = Brew.PathMap.createMapToPlayer(@my_level, @my_player.coordinates, monster, 10)
		
		if calc_from
			monster.pathmaps[Brew.paths.from_player] = Brew.PathMap.createMapFromPlayer(@my_level, @my_player.coordinates, monster, monster.pathmaps[Brew.paths.to_player], 10)

	setCurrentLevel: (level_id, arrive_xy) ->
		# setup screen/player for a new level
		@my_level = @levels[level_id]

		@my_level.setMonsterAt((if arrive_xy? then arrive_xy else @my_level.start_xy), @my_player)
		@my_level.updateLightMap()

		@refreshScheduler()
		
		# redo path maps 
		@updatePathMapsEndOfPlayerTurn()

		# automatically reset stamina on level change
		@my_player.getStat(Brew.stat.stamina).reset()

		# reset DOOM on level change
		@my_player.getStat(Brew.stat.doom).setTo(0)

		Brew.Sounds.play("new_level")

		# update all FOVs
		@updateAllFov()
		Brew.Display.centerViewOnPlayer()
		Brew.Display.drawDisplayAll()
		Brew.Display.drawHudAll()
		
	updateAllFov: () ->
		for monster in @my_level.getMonsters()
			if monster.objtype == "monster"
				monster.updateFov(@my_level)
		
		@updateCombinedEnemyFov()

		true

	updateCombinedEnemyFov: () ->
		# combine all monster FOVs into a single FOV
		dummy = Brew.monsterFactory("DUMMY")
		dummy.clearFov()

		for mob in @my_level.getMonsters()
			# skip the player
			if Brew.utils.compareThing(mob, @my_player)
				continue

			for own key, in_fov of mob.fov
				dummy.fov[key] = true


		@dummy_fov = dummy

	changeLevels: (portal) ->
		if portal.to_level_id == -1
			# create a new level, then switch to it
			next_id = @createLevel(@my_level.depth + 1)
			next_level = @levels[next_id]
			# next_level.setLinkedPortalAt(next_level.start_xy, @my_level.id, @my_level.exit_xy) # back up to this one
			@my_level.setLinkedPortalAt(@my_level.exit_xy, next_id, next_level.start_xy) # update link downwards
			@setCurrentLevel(next_id, next_level.start_xy)
			
		else
			# level already exists
			@setCurrentLevel(portal.to_level_id, portal.level_xy)

	createLevel: (depth) ->
		level = Brew.LevelGenerator.createLevel(depth, Brew.panels.game.width, Brew.panels.game.height, {})
		@levels[level.id] = level
		return level.id
		
	canApply: (item, applier) ->
		applier ?= @my_player
		return (
			applier.inventory.hasItem(item) and
			Brew.group[item.group].canApply
		)
	
	canEquip: (item, equipee) ->
		return false
		# equipee ?= @my_player
		# return (
		# 	equipee.inventory.hasItem(item) and
		# 	Brew.group[item.group].canEquip
		# )

	canRemove: (item, equipee) ->
		return false
		# equipee ?= @my_player
		# return (
		# 	equipee.inventory.hasItem(item) and
		# 	Brew.group[item.group].equip_slot and 
		# 	item.equip?
		# )
	
	canDrop: (item, dropper) ->
		dropper ?= @my_player
		return dropper.inventory.hasItem(item)

	canMove: (monster, terrain) ->
		if terrain.blocks_walking
			if terrain.can_open? and terrain.can_open
				return true
			else
				if monster.hasFlag(Brew.flags.is_flying.id) and not terrain.blocks_flying
					return true
				else
					return false
		else
			return true

	msg: (text) ->
		# console.log(text)
		# Brew.Display.addMessage(text, @turn)
		# Brew.Display.drawMessagesPanel()
		message_xy = @my_player.coordinates
		Brew.Display.showFloatingTextAbove(message_xy, text)

	msgFrom: (monster, text) ->
		# only show message if playe can see the monster
		if @my_player.hasKnowledgeOf(monster)
			@msg(text)

	doPlayerMoveTowards: (destination_xy) ->
		# called to move the player from a mouse click

		# only pathfind to a place we have been before
		knows_path = @my_player.canView(destination_xy) or @my_player.getMemoryAt(@my_level.id, destination_xy)?
		offset_xy = null

		if knows_path
			path = @findPath_AStar(@my_player, @my_player.coordinates, destination_xy)
		
			if path?
				next_xy = path[1]
				offset_xy = next_xy.subtract(@my_player.coordinates).asUnit()

		if not offset_xy?
			# just use simple directional offset
			offset_xy = destination_xy.subtract(@my_player.coordinates).asUnit()

		@movePlayer(offset_xy)
		
	movePlayer: (offset_xy) ->
		# potentially move the player to a new location or interact with that location
		new_xy = @my_player.coordinates.add(offset_xy)
		
		monster = @my_level.getMonsterAt(new_xy)
		t = @my_level.getTerrainAt(new_xy)
		
		if not @my_level.checkValid(new_xy)
			Brew.Sounds.play("bump")

			# @msg("You can't go that way")
			
		else if monster? #.objtype == "monster"
			@doPlayerBumpMonster(monster)

		else if t.blocks_walking and not (@my_player.hasFlag(Brew.flags.is_flying.id) and not t.blocks_flying)
			if t.can_apply?
				@doPlayerApplyTerrain(t, true)
					
			else
				# @msg("You can't move there")
				Brew.Sounds.play("bump")

		else
			# otherwise just move around
			Brew.Display.updateTerrainFooter(@my_player.coordinates, new_xy)
			@moveThing(@my_player, new_xy)
			Brew.Axe.onPlayerMove()
			@endPlayerTurn()

	getApplicableTerrain: (thing) ->
		# return a list of any terrain apply-able around a player/thing
		
		neighbors = thing.coordinates.getSurrounding()
		# neighbors = thing.coordinates.getAdjacent()
		# neighbors.push(thing.coordinates) # probably cant apply something you are standing on
		
		apply_list = []
		for xy in neighbors
			t = @my_level.getTerrainAt(xy)
			if t? and t?.can_apply == true
				apply_list.push([
					xy.subtract(thing.coordinates),
					t
				])
				
		return apply_list
		
	applyTerrain: (terrain, applier, bump) ->
		# apply some terrains, return true if something turn-ending happened
		if Brew.utils.isTerrain(terrain, "DOOR_CLOSED")
			@my_level.setTerrainAt(terrain.coordinates, Brew.terrainFactory("DOOR_OPEN"))
			return true
		
		else if Brew.utils.isTerrain(terrain, "DOOR_OPEN")
			@my_level.setTerrainAt(terrain.coordinates, Brew.terrainFactory("DOOR_CLOSED"))
			return true
			
		# else if Brew.utils.isTerrain(terrain, "ALTAR") and not bump
		# 	@msg("Your puny Gods cannot help you!")
		# 	return false
			
		@msg("You aren't sure how to apply that " + terrain.name)
		return false
		
	moveThing: (thing, new_xy, swap_override) ->
		swap_override ?= false

		# check for unwalkable but pathable terrain
		t = @my_level.getTerrainAt(new_xy)
		if Brew.utils.isTerrain(t, "DOOR_CLOSED")
			@applyTerrain(t, thing, true)
			return false # return false.. no successful movement 

		existing_monster = @my_level.getMonsterAt(new_xy)
		if existing_monster? and swap_override
			old_xy = thing.coordinates
			@my_level.setMonsterAt(new_xy, thing)
			@my_level.setMonsterAt(old_xy, existing_monster)

		else if existing_monster? and not swap_override
			console.error("attempting to move monster to location with existing monster")
			return false
		else
			old_xy = thing.coordinates
			@my_level.removeMonsterAt(old_xy)			
			@my_level.setMonsterAt(new_xy, thing)

		Brew.Display.drawMapAt(old_xy)
		Brew.Display.drawMapAt(new_xy)

		return true


	doPlayerAction: ->
		item = @my_level.getItemAt(@my_player.coordinates)
		portal = @my_level.getPortalAt(@my_player.coordinates)

		# interact with item on floor
		if item?
			# show info on screen
			if item.group == Brew.group.info.id
				Brew.Menu.popup.context = "info"
				Brew.Menu.popup.item = item
				Brew.Menu.showInfoScreen()
			
			# pickup
			else
				@doPlayerPickup(item)
		
		# change levels
		else if portal?
			@changeLevels(portal)
		
		# rest / skip
		else
			@doPlayerRest()
			
	doPlayerRest: () ->
		recharge = 1
		
		## cant rest during combat
		last_attacked = @my_player.last_attacked ? 0
		if (@turn - last_attacked) > Brew.config.wait_to_heal and (not @my_player.hasFlag(Brew.flags.poisoned.id))
			@my_player.getStat(Brew.stat.stamina).addTo(recharge)
			Brew.Display.drawHudAll()
		@endPlayerTurn()	
	
	doPlayerThrow: (item, target_xy) ->
		# should be guaranteed to work
		

		# if the item was equipped, remove it
		if item.equip?
			@my_player.inventory.unequipItem(item)
			Brew.Display.drawHudAll()

		# remove it from inventory
		@my_player.inventory.removeItemByKey(item.inv_key)
		
		traverse_lst = Brew.utils.getLineBetweenPoints(Brew.gamePlayer().coordinates, target_xy)
		@addAnimation(new Brew.ThrownEffect(@my_player, item, traverse_lst))
		@endPlayerTurn()

	doPlayerPickup: (item, end_turn) ->
		end_turn ?= true

		inv_key = @my_player.inventory.addItem(item)
		if not inv_key
			@msg("Inventory full")
		else
			@my_level.removeItemAt(@my_player.coordinates)
			@msg("Picked up")# + Brew.Catalog.getItemName(item) + " (" + item.inv_key_lower + ")")

			if end_turn
				@endPlayerTurn()
	
	doPlayerDrop: (item) ->
		if not item
			return false

		item_at = @my_level.getItemAt(@my_player.coordinates)
		if item_at?
			@msg("Something here already")#There's something on the ground here already.")
			return false
		
		if item.equip?
			@doPlayerRemove(item)
			
		@my_player.inventory.removeItemByKey(item.inv_key)
		@my_level.setItemAt(@my_player.coordinates, item)
		@msg("Dropped")#I'll just leave this here: " + Brew.Catalog.getItemName(item))
		return true
		
	doPlayerEquip: (item) ->
		if not item
			return false
		
		slot = Brew.group[item.group].equip_slot

		if not slot?
			@msg("??")#You're not sure where to put that...")
			return false

		existing = @my_player.inventory.getEquipped(slot)
		if existing?
			@doPlayerRemove(existing)
			
		@my_player.inventory.equipItem(item, slot)
		@msg("You are " + Brew.group[item.group].equip_verb + " " + Brew.Catalog.getItemName(item) + " (" + item.inv_key_lower + ")")
		Brew.Display.drawHudAll()
		return true
	
	doPlayerRemove: (item) ->
		if not item
			return false
		if not @canRemove(item)
			if not @canEquip(item)
				# @msg("I'm not sure how to remove that.")
				;
			else
				@msg("That's not equipped.")
			return false
			
		@my_player.inventory.unequipItem(item)
		@msg("You've stopped " + Brew.group[item.group].equip_verb + " " + Brew.Catalog.getItemName(item) + " (" + item.inv_key_lower + ")")
		Brew.Display.drawHudAll()
		return true
			
	doPlayerApply: (item, inv_key) ->
		if not item
			return false

		if not @canApply(item)
			@msg("Can't apply that")
			return false
		
		@applyItem(@my_player, item)
		
		true
		
	doPlayerApplyTerrain: (terrain, bump) ->
		success = @applyTerrain(terrain, @my_player, bump)
		if success
			@endPlayerTurn()
	
	applyItem: (applier, item) ->
		# let's do this
		
		# if item.group == Brew.group.flask.id
		# 	Brew.Interaction.Flask.use(@my_player, item)
			
		# else if item.group == Brew.group.wand.id
		# 	Brew.Interaction.Wand.use(@my_player, item)

		if item.group == Brew.group.scroll.id
			Brew.Interaction.Scroll.use(@my_player, item)

		else
			throw "error - non-appliable item"
			
	doPlayerBumpMonster: (bumpee) ->
		# shove / ally swap / feature interact 
		if bumpee.objtype == "monster"
			@meleeAttack(@my_player, bumpee)
			
		else if bumpee.objtype == "agent"
			Brew.Actor.handleBump(@, @my_player, bumpee)
			
		else
			throw "a horrible error happened when bumping a monster"
			
		@endPlayerTurn()
	
	canAttack: (attacker, target_mob) ->
		# returns true if melee or ranged attack is possible

		attack_range = attacker.getAttackRange()
		
		if attack_range == 0
			return false
		
		else if attack_range == 1
			# melee
			return (xy for xy in attacker.coordinates.getAdjacent() when xy.compare(target_mob.coordinates)).length > 0

		else if attack_range == 1.5
			# special melee + diagonal
			return (xy for xy in attacker.coordinates.getSurrounding() when xy.compare(target_mob.coordinates)).length > 0
			
		else
			return Brew.Targeting.checkSimpleRangedAttack(attacker, target_mob)[0]

	meleeAttack: (attacker, defender) ->
		return Brew.Combat.attack(attacker, defender, true)
		
	doMonsterAttack: (monster, defender) ->
		# called by the execute monster action function 
		# call melee or ranged attacks as necessary

		neighbors = defender.coordinates.getSurrounding()
		is_melee = neighbors.some((xy) -> monster.coordinates.compare(xy))

		if not is_melee
			# animate before calling the attack function
			start_xy = monster.coordinates
			target_xy = defender.coordinates

			traverse_lst = Brew.utils.getLineBetweenPoints(start_xy, target_xy)
			traverse_lst = traverse_lst[1..traverse_lst.length - 1]
			
			laserbeam = Brew.featureFactory("PROJ_MONSTERBOLT", {
				code: Brew.utils.getLaserProjectileCode(start_xy, target_xy)
				damage: monster.damage
			})
		
			@addAnimation(new Brew.ProjectileEffect(monster, laserbeam, traverse_lst))
			# console.log(traverse_lst)

		else
			Brew.Combat.attack(monster, defender, is_melee)

	gameOver: (killer, victim_player, is_melee, overkill_damage) ->
		console.log("you died!")
		Brew.Menu.showDied()

	doVictory: () ->
		console.log("you won!")
		Brew.Menu.showVictory()

	endPlayerTurn: () ->
		# update player pathmaps
		@turn += 1

		weapon = @my_player.inventory.getEquipped(Brew.equip_slot.melee)
		carrying_axe = weapon?

		if carrying_axe
			amount = 2
		else
			amount = 1

		Brew.Axe.increaseLevelOfDoom(amount)

		@updatePathMapsEndOfPlayerTurn()
		@nextTurn()

	updatePathMapsEndOfPlayerTurn: () ->
		# generic 'to player' pathmap
		@pathmaps[Brew.paths.to_player] = Brew.PathMap.createGenericMapToPlayer(@my_level, @my_player.coordinates, 10)

	runAnimationsOnly: () ->
		# runs animation turns, but does not end player turn
		@nextTurn(true)
		
	animationTurn: (animation, dont_end_player_turn) ->
		dont_end_player_turn ?= false

		animation.runTurn()
		if not animation.active
			@removeAnimation(animation)
		@finishEndPlayerTurn({update_all: animation.over_saturate, over_saturate: animation.over_saturate})
		setTimeout(=>
			@nextTurn(dont_end_player_turn)
		#Brew.config.animation_speed)
		animation.animation_speed)
		return

	nextTurn: (dont_end_player_turn) ->
		dont_end_player_turn ?= false

		if @hasAnimations()
			first_animation = @animations[0]
			@animationTurn(first_animation, dont_end_player_turn)
			return
		
		if dont_end_player_turn
			return

		next_actor = @scheduler.next()

		if Brew.Input.getInputHandler() in ["died", "victory"]
			return

		if next_actor.group == "player"
			# console.log("nextTurn: player is up, #queue: " + @scheduler._repeat.length)
			@checkFlagCounters(next_actor)
			@finishEndPlayerTurn({update_all: true, over_saturate: false})
			return

		if next_actor.objtype == "monster"
			monster = next_actor
			if monster.is_dead?
				console.error("trying to run a turn on a dead monster, should be removed from scheduler")
				debugger
					
			# console.log(monster.name + "'s turn, #queue: " + @scheduler._repeat.length)

			monster.updateFov(@my_level)
			@checkFlagCounters(next_actor)
			@ai.doMonsterTurn(monster)
			@finishEndPlayerTurn()
			@nextTurn()
			return

	finishEndPlayerTurn: (options) ->
		options ?= {}
		updateAll = options.update_all ? false
		overSaturate = options.over_saturate ? false

		# update the screen
		if updateAll
			lights = @my_level.updateLightMap()
			Brew.Display.drawMapAtList(lights)
			@updateAllFov()
			Brew.Display.centerViewOnPlayer()
			Brew.Display.drawDisplayAll({over_saturate: overSaturate})
			Brew.Display.drawOnScreenInfo()
			
	findPath_AStar: (thing, start_xy, end_xy) ->
		return @find_AStar(thing, start_xy, end_xy, false)
		
	findMove_AStar: (thing, start_xy, end_xy) ->
		return @find_AStar(thing, start_xy, end_xy, true)
		
	find_AStar: (thing, start_xy, end_xy, returnNextMoveOnly) ->
		passable_fn = (x, y) =>
			xy = new Coordinate(x, y)
			t = @my_level.getTerrainAt(xy)
			
			if t?
				if not @canMove(thing, t)
					return false
				else
					# terrain is passable but check for monsters
					m = @my_level.getMonsterAt(xy)
					if m?
						if thing.group == "player"
							return true
						else if thing.id == m.id
							return true
						else
							# hack - no need to route around far away monsters, just ones right next to you
							dist = Brew.utils.dist2d_xy(start_xy.x, start_xy.y, x, y)
							if dist == 1
								return false
							else
								return true
					else
						return true
			else
				# probably shouldnt be here
				return false
			
		path = []			
		update_fn = (x, y) ->
			path.push(new Coordinate(x, y))

		astar = new ROT.Path.AStar(end_xy.x, end_xy.y, passable_fn, {topology: 4})
		astar.compute(start_xy.x, start_xy.y, update_fn)

		next_xy = path[1]
		
		if returnNextMoveOnly
			return next_xy ? null
		else
			return path

	execMonsterTurnResult: (monster, result) ->
		# console.log("monster turn for #{monster.name} #{monster.id}", result)
		if result.action == "sleep"
			;
			
		else if result.action == "move"
			@moveThing(monster, result.xy)
			
		else if result.action == "wait"
			;
		
		else if result.action == "attack"
			@doMonsterAttack(monster, result.target)
			
		else if result.action == "stand"
			# monster is keeping its distance but doesn't need to move (usually would attack)
			# different from waiting because they wont give up after a while
			# if ROT.RNG.getUniform() < 0.25
			# 	@msgFrom(monster, monster.name + " glowers at you from afar.")
			;
			
		else if result.action == "special"
			# dont do anything (else)
			;
			
		else
			throw "unexpected AI result" 


	addAnimation: (new_animation) ->
		@animations.push(new_animation)

	removeAnimation: (my_animation) ->
		@animations = (a for a in @animations when a.id != my_animation.id)
		return true

	hasAnimations: () ->
		return @animations.length > 0

	doTargetingAt: (target_context, item_or_power, target_xy) ->
		# [can_use, data] = @abil.canUseAt(ability, target_xy)
		# if not can_use
		# 	@msg("#{data}")
		# 	return false

		# @abil.execute(ability, target_xy, false)
		if target_context == "throw"
			@doPlayerThrow(item_or_power, target_xy)
			return true

		else if target_context == "wand"
			Brew.Interaction.Wand.zap(item_or_power, target_xy)
		else
			console.error("unknown targeting context #{target_context}")
			return false

		return false

	# handle flag timeout for temp effects, needs to know game turn
	setFlagWithCounter: (thing, flag, effect_turns) ->
		thing.setFlagCounter(flag, effect_turns, @turn + effect_turns)
		true

	checkFlagCounters: (thing) ->
		for flag in thing.getFlagCounters()
			end_turn = thing.getFlagCount(flag)
			if end_turn <= @turn
				thing.removeFlagCounter(flag)

				if Brew.utils.compareThing(thing, @my_player)
					@msg("No longer #{flag}")
					Brew.Display.drawHudAll()
				else
					@msgFrom(thing, "#{thing.name} is no longer #{flag}")

			else
				# still burning!!!

				if flag == Brew.flags.on_fire.id
					if Brew.utils.compareThing(thing, @my_player)
						@my_player.getStat(Brew.stat.stamina).deduct(1)
						@my_player.last_attacked = @turn
						Brew.Display.drawHudAll()
					else
						thing.getStat(Brew.stat.health).deduct(1)
						if thing.getStat(Brew.stat.health).isZero()
							@killMonster(@my_player, thing, false, 0)

		true


	debugClick: (map_xy) ->
		debug_id = $("#id_select_debug").val()
		[objtype, def_id] = debug_id.split("-")
		if objtype == "MONSTER"
			monster = Brew.monsterFactory(def_id)
			@my_level.setMonsterAt(map_xy, monster)
			Brew.Display.drawMapAt(map_xy)
			@scheduler.add(monster, true)

	debugDropdownMenu: () ->
		# populate a dropdown menu with stuff
		for own def_id, monster_def of Brew.monster_def
			if def_id == "PLAYER" then continue
			$("#id_select_debug").append("<option value=\"MONSTER-#{def_id}\">#{def_id}</option>")
