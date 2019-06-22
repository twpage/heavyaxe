# try to keep 7DRL-specific stuff here so I can paste it back into the main 'brew' "engine"
# ugggg

Brew.Axe =
	doPlayerDropAxe: () ->
		level = Brew.gameLevel()
		player = Brew.gamePlayer()

		item_at = level.getItemAt(player.coordinates)
		if item_at?
			Brew.msg("Something's here")
			return false
		
		axe = player.inventory.getEquipped(Brew.equip_slot.melee)
		if not axe
			Brew.msg("No Axe")
			return false

		Brew.Game.doPlayerRemove(axe)
		
		player.inventory.removeItemByKey(axe.inv_key)
		level.setItemAt(player.coordinates, axe)
		# Brew.msg("The #{Brew.Catalog.getItemName(axe)} drops to the floor.")
		Brew.Display.drawHudAll()

		Brew.Sounds.play("dropaxe")
		Brew.Game.endPlayerTurn()
		return true


	doPlayerSelectInventoryHotKey: (keycode) ->
		# apply an item from hotkeys if available
		player = Brew.gamePlayer()

		# convert from keycode to numeric hotkey
		index = keycode - 49

		if index < 0 or index >= Brew.ItemType.list_of.scroll.length
			console.error("bad hotkey was pressed #{keycode}")

		# find the type of scroll
		item_type = Brew.ItemType.list_of.scroll[index]

		# see if we have any in inventory
		items_of_type = (i for i in player.inventory.getItems() when i.group == Brew.group.scroll.id and i.itemType == item_type)
		if items_of_type.length == 0
			Brew.msg("No scrolls")
			return false

		# otherwise use it!
		inv_key = String.fromCharCode(keycode)
		item = items_of_type[0]
		Brew.Game.doPlayerApply(item, inv_key)


	doPlayerAction: () ->
		level = Brew.gameLevel()
		player = Brew.gamePlayer()

		item = level.getItemAt(player.coordinates)
		portal = level.getPortalAt(player.coordinates)

		# interact with item on floor
		if item?
			# show info on screen
			if item.group == Brew.group.info.id
				Brew.Menu.popup.context = "info"
				Brew.Menu.popup.item = item
				Brew.Menu.showInfoScreen()

			else if item.group == Brew.group.rune.id
				Brew.Interaction.Rune.use(player, item)

		# change levels
		else if portal?
			# make sure we have the axe before we leave
			wpn_equipped = player.inventory.getEquipped(Brew.equip_slot.melee)
			if not wpn_equipped?
				Brew.msg("Need the Axe")
			else
				Brew.Game.changeLevels(portal)
		
		# rest / skip
		else
			Brew.Axe.doPlayerRest()
			
	finishRecallAxe: (item) ->
		player = Brew.gamePlayer()
		level = Brew.gameLevel()

		Brew.Axe.pickupAndWieldAxe(item, true)
		# player.inventory.addItem(item)

		# weapon = player.inventory.getEquipped(Brew.equip_slot.melee)
		# if weapon?
		# 	console.error("somehow two weapons...?")
		
		# player.inventory.equipItem(item, Brew.equip_slot.melee)
		# Brew.Display.drawHudAll()
		

	doPlayerRest: () ->
		player = Brew.gamePlayer()

		# keep track of how long we have been on this tile
		# if not player.current_tile_turns?
		# 	player.current_tile_turns = 1
		# else
		# 	player.current_tile_turns += 1

		# recharge stamina when resting
		recharge = 1
		
		## cant rest during combat
		# last_attacked = @my_player.last_attacked ? 0
		# if (@turn - last_attacked) > Brew.config.wait_to_heal and (not @my_player.hasFlag(Brew.flags.poisoned.id))
		
		player.getStat(Brew.stat.stamina).addTo(recharge)
		Brew.Display.drawHudAll()
		Brew.Axe.doPlayerTaunt()


		# Brew.Game.endPlayerTurn()

	onPlayerMove: () ->
		level = Brew.gameLevel()
		player = Brew.gamePlayer()

		# stamina decreases as you walk with axe
		weapon = player.inventory.getEquipped(Brew.equip_slot.melee)
		carrying_axe = weapon?

		if carrying_axe
			player.getStat(Brew.stat.stamina).deduct(1)
			Brew.Display.drawHudAll()
		else
			# stamina increases as you walk without axe
			player.getStat(Brew.stat.stamina).addTo(1)
			Brew.Display.drawHudAll()

		# reset rest time when we move
		player.current_tile_turns = 0

		# if we walk on an item, pick it up
		item_at = level.getItemAt(player.coordinates)
		if item_at?
			if item_at.group == Brew.group.weapon.id
				Brew.Sounds.play("pickup")
				Brew.Axe.pickupAndWieldAxe(item_at)

			else if item_at.group == Brew.group.rune.id
				# do nothing for runes until we rest on them
				;

			else
				inv_key = player.inventory.addItem(item_at)
				if not inv_key
					Brew.msg("Inventory Full")
				else
					level.removeItemAt(player.coordinates)
					Brew.msg("Picked up")# #{Brew.Catalog.getItemName(item_at)} (#{item_at.inv_key_lower})")
					Brew.Sounds.play("pickup")
					

	pickupAndWieldAxe: (should_be_axe, from_recall) ->
		from_recall ?= false

		level = Brew.gameLevel()
		player = Brew.gamePlayer()

		weapon = player.inventory.getEquipped(Brew.equip_slot.melee)
		carrying_axe = weapon?

		# walked into the axe (or another weapon??)
		if carrying_axe
			console.error("something horrible happened with another weapon")

		inv_key = player.inventory.addItem(should_be_axe, "0") # add to inventory no matter what
		if not from_recall
			level.removeItemAt(should_be_axe.coordinates)
		# Brew.msg("Retrieved the #{Brew.Catalog.getItemName(should_be_axe)} (#{should_be_axe.inv_key_lower})")
		player.inventory.equipItem(should_be_axe, Brew.equip_slot.melee)
		Brew.Display.drawHudAll()

	doPlayerTaunt: () ->
		level = Brew.gameLevel()
		player = Brew.gamePlayer()

		# keep track of how long we have been on this tile
		if not player.current_tile_turns?
			player.current_tile_turns = 1
		else
			player.current_tile_turns += 1

		# Brew.msg("Raarrr! #{player.current_tile_turns}")

		Brew.Axe.increaseLevelOfDoom(1)

		radius = Math.min(Brew.config.max_taunt_radius, player.current_tile_turns + 1)
		Brew.Game.addAnimation(new Brew.TauntEffect(Brew.gamePlayer().coordinates, radius, Brew.colors.red))
		# Brew.Display.showFloatingTextAbove(player.coordinates, "Rarrrr!", Brew.colors.red)

		Brew.Game.endPlayerTurn()

	tauntMonsterAt: (target_xy) ->
		m = Brew.gameLevel().getMonsterAt(target_xy)
		if m? and not Brew.utils.compareThing(m, Brew.gamePlayer())
			Brew.Axe.tauntMonster(m)

	tauntMonster: (monster) ->
		# console.log("taunting #{monster.name}")
		monster.last_player_xy = Brew.gamePlayer().coordinates
		monster.status = Brew.monster_status.HUNT
		monster.giveup = 0
		Brew.Game.setFlagWithCounter(monster, Brew.flags.is_angry.id, 5)
		# setFlagWithCounter: (thing, flag, effect_turns) ->
		

		# if monster.status == Brew.monster_status.SLEEP and monster.hasFlag(Brew.flags.is_passive.id)
		# 	monster.status == Brew.monster_status.HUNT
		
	updateOnKill: (victim, is_melee, overkill) ->
		Brew.gamePlayer().getStat(Brew.stat.stamina).reset()
		Brew.Display.drawHudAll()

		monsters = (m for m in Brew.gameLevel().getMonsters() when not Brew.utils.compareDef(m, "WARDEN"))
		if monsters.length == 1 # killt all monsters
			Brew.Axe.createPortalToNextLevel()

	createPortalToNextLevel: () ->
		level = Brew.gameLevel()
		player = Brew.gamePlayer()

		# if we already hve an exit, skip this
		if level.exit_xy? and level.checkValid(level.exit_xy)
			return false

		# figure out where to make our exit, nearby
		exit_xy = null
		exit_ranking = {}

		neighbors = player.coordinates.getAdjacent()
		neighbors = neighbors.randomize()
		for neighbor_xy in neighbors
			if not level.checkValid(neighbor_xy)
				continue

			exit_ranking[neighbor_xy.toKey()] = 0
			
			t = level.getTerrainAt(neighbor_xy)
			if t.blocks_walking
				exit_ranking[neighbor_xy.toKey()] += 1

			i = level.getItemAt(neighbor_xy)
			if i?
				exit_ranking[neighbor_xy.toKey()] += 1

		lowest_ranking = Math.min.apply @, (val for own k, val of exit_ranking)

		for own key, rank of exit_ranking
			if rank == lowest_ranking
				exit_xy = keyToCoord(key)
				break

		if not exit_xy?
			console.error("something terrible has happened!")

		level.exit_xy = exit_xy
		level.setUnlinkedPortalAt(exit_xy)
		level.setTerrainAt(exit_xy, Brew.terrainFactory("STAIRS_DOWN"))
		Brew.Display.drawMapAt(exit_xy)
		return true

	findSafeLevelCoordinates: (min_monster_distance) ->
		# try to find a safe spot, a minimum distance away from any monsters
		# todo: or traps?

		player = Brew.gamePlayer()
		level = Brew.gameLevel()

		monster_locations = (m.coordinates for m in level.getMonsters() when not Brew.utils.compareThing(m, player))

		if monster_locations.length == 0
			xy = level.getRandomWalkableLocation()
			return xy

		tries = 0
		final_xy = null
		while tries < 25
			xy = level.getRandomWalkableLocation()

			monster_at = level.getMonsterAt(xy)
			if monster_at?
				tries += 1
				continue

			item_at = level.getItemAt(xy)
			if item_at?
				tries += 1
				continue
				
			distances = (Brew.utils.dist2d(xy, m_xy) for m_xy in monster_locations)
			min_distance = Math.min.apply @, distances

			if min_distance <= min_monster_distance
				tries += 1
				continue

			final_xy = xy
			break

		if not final_xy?
			final_xy = level.getRandomWalkableLocation()

		return final_xy


	doRecallAxeWithPath: (recall_path, axe_xy) ->
		# called from the recall targeting 'menu'

		player = Brew.gamePlayer()
		level = Brew.gameLevel()

		if not recall_path? or recall_path.length == 0
			console.error("error pathing back to player")

		# remove ye axe - assuming first coordinate is the axe ??
		axe_item = level.getItemAt(axe_xy)
		level.removeItemAt(axe_xy)
		
		# smash everything
		# bolt = Brew.featureFactory("PROJ_AXE_RECALL")
		# axe_item = Math.min(Brew.config.max_recall_damage, recall_path.length)
		Brew.Game.addAnimation(new Brew.RecallEffect(player, axe_item, recall_path))
		Brew.Game.endPlayerTurn()

	doRecallAxe: (from_item) ->
		# summons the axe back to the player (if dropped) and smashes everything on the way back

		player = Brew.gamePlayer()
		level = Brew.gameLevel()

		axe = Brew.gamePlayer().inventory.getEquipped(Brew.equip_slot.melee)
		if axe?
			Brew.msg("Axe in hand")# vibrates in your hand.")

		else
			# find the axe?
			axe_list = (i for i in level.getItems() when i.group == Brew.group.weapon.id)
			if not axe_list? or axe_list.length == 0
				console.error("something bad happened when finding the axe")
			else if axe_list.length > 1
				console.error("something WEIRD happened when finding the axe")

			axe_item = axe_list[0]
			axe_xy = axe_item.coordinates

			if axe_xy.compare(player.coordinates)
				Brew.msg("Axe at location")

			else
				# recall_path = getRecallAxePath(axe_xy, player.coordinates)

				# if not recall_path? or recall_path.length == 0
				# 	console.error("error pathing back to player")

				# # remove ye axe
				# level.removeItemAt(axe_xy)
				
				# # smash everything
				# # bolt = Brew.featureFactory("PROJ_AXE_RECALL")
				# # axe_item = Math.min(Brew.config.max_recall_damage, recall_path.length)
				# Brew.Game.addAnimation(new Brew.RecallEffect(player, axe_item, recall_path))

				Brew.Menu.popup.axe_xy = axe_xy
				Brew.Menu.showRecall()

	explodeOnDeath: (victim) ->
		bolt = Brew.featureFactory("PROJ_EXPLOSION")
		bolt.damage = 1
		for surround_xy in victim.coordinates.getSurrounding()
			if Brew.gameLevel().checkValid(surround_xy)
				# console.log(surround_xy)
				Brew.Game.addAnimation(new Brew.ProjectileEffect(victim, bolt, [surround_xy]))

	respawnOnDeath: (victim) ->
		level = Brew.gameLevel()
		respawn_xy = Brew.Axe.findSafeLevelCoordinates(4)

		old_hp = victim.getStat(Brew.stat.health).getMax()

		new_monster = Brew.monsterFactory(victim.def_id)
		new_monster.createStat(Brew.stat.health, old_hp+1)

		level.setMonsterAt(respawn_xy, new_monster)
		Brew.Game.scheduler.add(new_monster, true)
		return true

	getScrollStack: () ->
		# return a dictionary of scrolls by type
		
		scroll_stack = {}
		for scroll_type in Brew.ItemType.list_of.scroll
			scroll_stack[scroll_type] = []

		for item in Brew.gamePlayer().inventory.getItems()
			if item.group != Brew.group.scroll.id
				continue

			scroll_stack[item.itemType].push(item)


		return scroll_stack

	getScrollInventory: () ->
		# return a classier scroll stack
		scroll_stack = Brew.Axe.getScrollStack()

		return new Brew.ScrollInventory(scroll_stack)

	increaseLevelOfDoom: (amount) ->
		amount ?= 1
		# increase doom after each turn
		player = Brew.gamePlayer()
		player.getStat(Brew.stat.doom).addTo(amount)

		# if doom is at the max, summon the warden
		if player.getStat(Brew.stat.doom).isMax() 
			Brew.Axe.summonWarden()

	summonWarden: () ->
		level = Brew.gameLevel()

		# make sure we dont already have a warden
		if level.has_warden?
			return false # already have one

		# otherwise we need a new one
		level.has_warden = true
		
		# warden persists across levels, and gets stronger each time
		if Brew.Game.persist_warden?
			# already have a warden from a previous level, bring it back and reset health
			warden = Brew.Game.persist_warden
			warden.getStat(Brew.stat.health).reset()
			delete warden.is_dead

		else
			# we need a brand new warden
			warden = Brew.monsterFactory("WARDEN")
			Brew.Game.persist_warden = warden

		spawn_xy = Brew.Axe.findSafeLevelCoordinates(4)
		Brew.gameLevel().setMonsterAt(spawn_xy, warden)
		Brew.Game.scheduler.add(warden, true)

		return true

	getRecallPaths: () ->
		return new Brew.PathLibrary(Brew.Menu.popup.axe_xy, Brew.gamePlayer().coordinates)

getRecallAxePath = (start_xy, end_xy, startIsNotAxe) ->
	startIsNotAxe ?= false
	path = []

	recall_axe_passable_fn = (x, y) =>
		xy = new Coordinate(x, y)
		t = Brew.gameLevel().getTerrainAt(xy)
		i = Brew.gameLevel().getItemAt(xy)

		# if we started away from the axe, then skip over the axe location itself
		if i? and startIsNotAxe and i.group == Brew.group.weapon.id
			return false

		if t?
			if t.blocks_walking
				return false
			else
				# terrain is passable but check for monsters
				m = Brew.gameLevel().getMonsterAt(xy)
				if m?
					if m.group == "player"
						if startIsNotAxe
							return false
						else
							return true
					else
						# smash all monsters en-route back to the player
						return true
				else
					return true
		
		else
			# probably shouldnt be here
			return false
		
	update_fn = (x, y) ->
		path.push(new Coordinate(x, y))

	astar = new ROT.Path.AStar(end_xy.x, end_xy.y, recall_axe_passable_fn, {topology: 4})
	astar.compute(start_xy.x, start_xy.y, update_fn)

	return path

class window.Brew.PathLibrary
	constructor: (start_xy, end_xy) ->
		@path_list = []
		
		# vary starting point 
		start_points = []
		for neighbor_xy in start_xy.getAdjacent()
			if Brew.gameLevel().checkValid(neighbor_xy) and (not Brew.gameLevel().getTerrainAt(neighbor_xy).blocks_walking)
				start_points.push(neighbor_xy)

		# vary ending point
		end_points = []
		for neighbor_xy in end_xy.getAdjacent()
			if Brew.gameLevel().checkValid(neighbor_xy) and (not Brew.gameLevel().getTerrainAt(neighbor_xy).blocks_walking)
				end_points.push(neighbor_xy)

		# add extra paths
		for new_start_xy in start_points
			for new_end_xy in end_points
				adj_path = getRecallAxePath(new_start_xy, new_end_xy, true)

				if not adj_path? or adj_path.length == 0
					continue

				adj_path.unshift(start_xy)
				adj_path.push(end_xy)
				@path_list.push(adj_path)

		if @path_list.length == 0
			# somehow failed to grab a good path using adjacent tiles
			# add primary path
			@path_list.push(getRecallAxePath(start_xy, end_xy))

		@index = 0


	getCurrentPath: () ->
		return @path_list[@index]

	next: () ->
		return @rotate( 
			(a, b) => 
				a + b 
			)

	prev: () ->
		return @rotate( 
			(a, b) => 
				a - b 
			)

	rotate: (fn) ->
		next_index = fn(@index, 1).mod(@path_list.length)
		@index = next_index
		return true

class window.Brew.ScrollInventory
	constructor: (scroll_stack) ->
		@scroll_count = {}
		@scroll_example = {}
		@scroll_list = []
		@index = null

		i = 0
		for own scroll_type, scroll_item_list of scroll_stack
			@scroll_list.push(scroll_type)
			@scroll_count[scroll_type] = scroll_item_list.length
			
			if scroll_item_list.length > 0 and @index == null
				@index = i

			@scroll_example[scroll_type] = if scroll_item_list.length > 0 then scroll_item_list[0] else null
			i += 1

		return @index != null

	getNumberOf: (scroll_type) ->
		return @scroll_count[scroll_type]

	getExampleOf: (scroll_type) ->
		return @scroll_example[scroll_type]

	next: () ->
		return @rotate( 
			(a, b) => 
				a + b 
			)

	prev: () ->
		return @rotate( 
			(a, b) => 
				a - b 
			)

	rotate: (fn) ->
		for i in [1..@scroll_list.length]
			next_index = fn(@index, i).mod(@scroll_list.length)
			next_type = @scroll_list[next_index]
			if @getNumberOf(next_type) > 0
				@index = next_index
				return true

		return false

	getNumberOfCurrent: () ->
		current_type = @scroll_list[@index]
		return @getNumberOf(current_type)

	getExampleOfCurrent: () ->
		current_type = @scroll_list[@index]
		return @getExampleOf(current_type)
