class window.Brew.MonsterAI
	constructor: (@game) ->
		@id = null
		
	msg: (text) ->
		@game.msg(text)
		
	doMonsterTurn: (monster) ->
		# see if we can move
		if monster.hasFlag(Brew.flags.is_stunned.id)
			# i can't move...
			return false

		# change state if necessary
		@updateState(monster)
		
		# pick an action and then do it
		result = @getAction(monster)
		
		# do it!
		monster.last_xy = monster.coordinates
		@game.execMonsterTurnResult(monster, result)
		return true
		
	updateState: (monster) ->
		# handle state changes 
		
		# can we sense/see the player?
		me_sense_player = monster.hasKnowledgeOf(@game.my_player)
		horde_sense_player = if monster.horde? then monster.horde.hasKnowledgeOf(@game.my_player) else false
		sense_player = me_sense_player or horde_sense_player
		is_hunting = false

		# if sense_player
		# 	console.log("sensed player")

		# should we run away?
		if monster.status != Brew.monster_status.ESCAPE and monster.hasFlag(Brew.flags.flees_when_wounded.id)
			if not monster.getStat(Brew.stat.health).isMax()
				@msg(monster.name + " flees!")
				monster.status = Brew.monster_status.ESCAPE
				return true # don't need to worry about any other state changes
		
		# SLEEP sleeping... zzzzz
		if monster.status == Brew.monster_status.SLEEP
			# chance we will wake up		
			;
			
		# WANDER or GUARD
		else if monster.status in [Brew.monster_status.WANDER, Brew.monster_status.GUARD]
			# change if we notice the player
			if sense_player
				# chance we wont notice?
				# verb = " spots " # if sense_player then " spots " else " senses "
				# @msg(monster.name + verb + "you!") # >:O X| 
				# @game.ui.showDialogAbove(monster.coordinates, Brew.Messages.getRandom("alarm"), Brew.colors.red)
				monster.status = Brew.monster_status.HUNT

				if monster.hasFlag(Brew.flags.is_passive.id) # dbl sight radius on hunt
					monster.sight_radius = monster.sight_radius * 2

				is_hunting = true
				
		# HUNT
		else if monster.status == Brew.monster_status.HUNT
			# if we cant see the player, increment the giveup timer
			if !sense_player

				# only give up after we can see the last known spot
				if monster.canView(monster.last_player_xy)
					monster.giveup = if monster?.giveup then monster.giveup + 1 else 1
					
					# give up after a while and go back to wandering
					if monster.giveup > 4
						@giveUpHunting(monster)
						
			# we can still see the player
			else
				is_hunting = true
				
		# ESCAPE
		else if monster.status == Brew.monster_status.ESCAPE
			if sense_player
			 	@game.updatePathMapsFor(monster, true)

			# healed?
			if monster.hp == monster.maxhp 
				monster.status = Brew.monster_status.HUNT

		
		if is_hunting
			# every time we see the player, reset the givup timer
			monster.giveup = 0

			# update where we last saw the player in case they disappear
			monster.last_player_xy = @game.my_player.coordinates

			is_angry = monster.hasFlag(Brew.flags.is_angry.id)
			keeps_distance = if is_angry then false else monster.hasFlag(Brew.flags.keeps_distance.id)
		
			@game.updatePathMapsFor(monster, keeps_distance)

		return true
	
	giveUpHunting: (monster) ->
		if monster.hasFlag(Brew.flags.is_passive.id)
			monster.status = Brew.monster_status.GUARD
			monster.sight_radius = monster.sight_radius / 2

		else
			monster.status = Brew.monster_status.WANDER

		# @msg(monster.name + " gives up the hunt.")
		Brew.Display.showFloatingTextAbove(monster.coordinates, "?", Brew.colors.red)
		monster.giveup = 0
		return true

	getAction: (monster) ->
		# determine what the monster should be doing based on state (HUNT/WANDER/etc) 
		
		# can we sense/see the player?
		me_sense_player = monster.hasKnowledgeOf(@game.my_player)
		horde_sense_player = if monster.horde? then monster.horde.hasKnowledgeOf(@game.my_player) else false
		sense_player = me_sense_player or horde_sense_player
		
		# can we move?
		is_immobile = monster.hasFlag(Brew.flags.is_immobile.id)

		# here is our default action construct
		result = 
			action: null
			xy: monster.coordinates
			target: null

		# SLEEP : no action
		if monster.status == Brew.monster_status.SLEEP
			result.action = "sleep"
			
		# GUARD : guarding monsters dont wander around
		else if monster.status == Brew.monster_status.GUARD
			result.action = "wait"
			result.note = "guard"

		# WANDER : continue to wander
		else if monster.status == Brew.monster_status.WANDER
			# change wander destinations after a while
			if monster.giveup > 4 or (monster.wander_xy? and monster.coordinates.compare(monster.wander_xy))
				monster.giveup = 0
				monster.wander_xy = null

			# randomly change wander destinations every now and then
			if ROT.RNG.getUniform() < 0.20
				monster.giveup = 0
				monster.wander_xy = null				
				
			result.action = "move"
			result.xy = @getWanderMove(monster)
		
		# ESCAPE : run away
		else if (monster.status == Brew.monster_status.ESCAPE) or monster.hasFlag(Brew.flags.is_scared.id)
			# if we can see the player, update our personal escape map
			# if sense_player
			# 	@game.updatePathMapsFor(monster, true)
				
			result.action = "move"
			result.xy = @getMoveAwayFromPlayer(monster)
		
		# IMMOBILE HUNT : attack only
		else if monster.status == Brew.monster_status.HUNT and is_immobile
			if sense_player and @game.canAttack(monster, @game.my_player)
				result.action = "attack"
				result.xy = @game.my_player.coordinates
				result.target = @game.my_player
			else
				result.action = "wait"
				result.note = "immobile hunt"

		# HUNT : attack or move towards player
		else if monster.status == Brew.monster_status.HUNT and (not is_immobile)
			
			is_angry = monster.hasFlag(Brew.flags.is_angry.id)
			keeps_distance = if is_angry then false else monster.hasFlag(Brew.flags.keeps_distance.id)
			
			if monster.hasFlag(Brew.flags.attacks_in_group.id) and @checkAttackGroup(monster) 
				# console.log("in a group - override ")
				keeps_distance = false

			# do we know where the player is?
			if sense_player
				# @game.updatePathMapsFor(monster, keeps_distance)
				
				# try to keep our distance, but sometimes this will fail in corner situations
				keeping_distance = false
				
				if keeps_distance
					decision_result = @getKeepDistanceDirection(monster)
					# console.log("keeps distance: ", decision_result)
					decision = decision_result.direction
					
					if decision == "forward"
						keepdistance_xy = @getMoveTowardsPlayer(monster)

					else if decision == "back" 
						keepdistance_xy = @getMoveAwayFromPlayer(monster)
					else
						keepdistance_xy = null

					# did we find somewhere else to turn?
					if keepdistance_xy? and not keepdistance_xy.compare(monster.coordinates)
						# if so.. move
						result.action = "move"
						result.xy = keepdistance_xy
						result.note = "successfull keep distance"
						keeping_distance = true
				
				# if we're not keeping our distance (either we tried and failed or we don't care...)
				if not keeping_distance
					special_ability = @canUseSpecialAbility(monster)
					
					if special_ability
						result.action = "special"
						@doSpecialAbility(monster, special_ability)
						
					# can we attack this player?
					else if @game.canAttack(monster, @game.my_player)
						result.action = "attack"
						result.xy = @game.my_player.coordinates
						result.target = @game.my_player
					
					# no abilities, can't attack, but want to keep distance?
					else if keeps_distance
						console.log("keeping distance - stand")
						result.action = "stand"
					
					# otherwise, move towards player
					else
						result.action = "move"
						result.xy = @getMoveTowardsPlayer(monster)
				
			else
				# we lost them but move to last location 
				result.action = "move"
				result.xy = @game.findMove_AStar(monster, monster.coordinates, monster.last_player_xy)
			
			
		# POST PROCESSING modifications to Actions
		if result.action == "move" and is_immobile # immobile monsters can't move!
			result.action = "wait"
			result.note = "immobile can't move"

		else if result.action == "wait"
			monster.giveup = if monster?.giveup then monster.giveup + 1 else 1

		else if result.action == "move"
			# pathfinding returned a null
			# if result.xy == null
			if not result.xy?
				result.action = "wait"
				result.note = "no valid xy on move action"
				monster.giveup = if monster?.giveup then monster.giveup + 1 else 1				
				
			else
				# can we get to where we want to go?
				monster_at = @game.my_level.getMonsterAt(result.xy)
				if monster_at?
					# we found the player (by accident?)
					if monster_at.group == "player"
						result.action = "attack"
						result.target = @game.my_player
						
					# we ran into another monster, tell them where player is, if they are escaping
					else if monster.status == Brew.monster_status.ESCAPE and monster_at.status == Brew.monster_status.ESCAPE
						monster_at.pathmaps[Brew.paths.from_player] = monster.pathmaps[Brew.paths.from_player]
						result.action = "wait"
						result.note = "escape blocked by non-player monster"
						
					else
						# it is another monster but we have to wait
						result.action = "wait"
						result.xy = null
						result.target = null
						result.note = "move blocked by non-player monster"
			
		return result
	
	checkAttackGroup: (monster) ->
		# returns true if monster is in a 'group' for use in attacks_in_group
		allies = []
		for monster_id in monster.knowledge
			monster = Brew.gameLevel().getMonsterById(monster_id)

			if not monster?
				continue

			# todo: change this if the player ever has allies
			if not Brew.utils.compareThing(monster, Brew.gamePlayer())
				allies.push(monster)

		# console.log("allies: ", allies.length)
		return allies.length >= 1

	getWanderMove: (monster) ->
		# see if we already have a wandering point
		if not monster.wander_xy?
			# make one
			monster.wander_xy = @game.my_level.getRandomWalkableLocation()
			
		else if monster.wander_xy.compare(monster.coordinates)
			# already there, make a new one
			monster.wander_xy = @game.my_level.getRandomWalkableLocation()
		
		# where do we want to go?
		next_xy = @game.findMove_AStar(monster, monster.coordinates, monster.wander_xy)
		return next_xy
		
	getKeepDistanceDirection: (monster) ->
		# decide what a monster trying to keep their distance should do (ahead, back, stay)
		stand_value = monster.pathmaps[Brew.paths.to_player][monster.coordinates.toKey()]
		direction = null

		if stand_value < monster.keeps_distance
			direction = "back"
		else if stand_value > monster.keeps_distance
			direction = "forward"
		else
			direction = "stand"

		return {
			direction: direction
			stand_value: stand_value
			keeps_distance: monster.keeps_distance
		}
		
	getMoveAwayFromPlayer: (monster) ->
		# use personal escape map to run away!
		
		next_xy = null
		
		# check if we have an escape map
		if not monster.pathmaps[Brew.paths.from_player]?
			# uh oh
			console.log("monster tried to run away without escape map")
			next_xy = getWanderMove(monster)
			
		else
			# we have one, use it
			path_xy = Brew.PathMap.getDownhillNeighbor(monster.pathmaps[Brew.paths.from_player], monster.coordinates).xy
			if not path_xy?
				console.log("getMoveAwayFromPlayer null path")
			else
				m = @game.my_level.getMonsterAt(path_xy)
				if m? and m.group != "player" and not Brew.utils.compareThing(monster, m)
					console.log("getMoveAwayFromPlayer monster collision")
				else
					next_xy = path_xy

		return next_xy
		
	getMoveTowardsPlayer: (monster) ->
		# use personal approach map to move towards player
		
		next_xy = null
		
		# check if we have an escape map
		# if not monster.pathmaps[Brew.paths.to_player]?
		if not @game.pathmaps[Brew.paths.to_player]?
			# uh oh
			console.log("monster tried to move towards player without map")
		
		else
			# we have one, use it
			path_xy = Brew.PathMap.getDownhillNeighbor(@game.pathmaps[Brew.paths.to_player], monster.coordinates).xy
			m = if path_xy? then @game.my_level.getMonsterAt(path_xy) else null
			
			if (not path_xy?) or (m? and m.group != "player")
				next_xy = @game.findMove_AStar(monster, monster.coordinates, @game.my_player.coordinates)
				console.log("astar override for #{monster.id}: " + next_xy)

			else
				next_xy = path_xy
		
		return next_xy
			
	canUseSpecialAbility: (monster) ->
		can_use = null
		# if monster.hasFlag(Brew.flags.summons_zombies.id)
		# 	# count number of zombies already on the level
		# 	get_zombies = (m for m in @game.my_level.getMonsters() when m.group.toUpperCase() in ["ZOMBIE", "ZOMBIE_LIMB"])
		# 	if get_zombies.length == 0
		# 		can_use = Brew.flags.summons_zombies.id

		return can_use
		
	doSpecialAbility: (monster, special_ability) ->
		if special_ability == Brew.flags.summons_zombies.id
			return true
			
		else
			console.log("unrecognized special ability: " + special_ability)
			return false
