class window.Brew.Effect extends Brew.Thing
	constructor: (effect_type) ->
		super "effect"
		@effectType = effect_type
		@turn = 0
		@active = true
		@over_saturate = false
		@animation_speed = Brew.config.animation_speed

	runTurn: () ->
		@cleanup()
		@turn += 1
		@update()

	getSpeed: ->
		return 10000

class window.Brew.FlashEffect extends Brew.Effect
	constructor: (@flash_xy, @flash_color) ->
		super "effect_flash"
		@lastOverhead = null

	cleanup: () ->
		if @turn == 1
			if @lastOverhead?
				Brew.gameLevel().setOverheadAt(@flash_xy, @lastOverhead)
			else
				Brew.gameLevel().removeOverheadAt(@flash_xy)

			Brew.Display.drawMapAt(@flash_xy)
			# game.finishAttack(@attacker, @defender, true, 0)

	update: () ->
		if @turn == 1
			overhead = Brew.gameLevel().getOverheadAt(@flash_xy)

			if overhead?
				@lastOverhead = overhead

			flash = Brew.featureFactory("TILE_FLASH", {color: @flash_color})
			Brew.gameLevel().setOverheadAt(@flash_xy, flash)
			Brew.Display.drawMapAt(@flash_xy)
			# console.log("drawing flash at " + @flash_xy)

		else
			@active = false

class window.Brew.ProjectileEffect extends Brew.Effect
	constructor: (@original_attacker, @projectile_feature, @full_path_lst) ->
		super "effect_projectile"
		@lastOverhead = null
		if @projectile_feature?.light_source?
			@over_saturate = true

	cleanup: () ->
		# no cleanup on turn 0
		if @turn == 0
			return

		idx = @turn - 1
		if idx >= @full_path_lst.length
			console.log("tried to clean up bad index " + idx)
			return

		last_xy = @full_path_lst[idx]
		if @lastOverhead?
			Brew.gameLevel().setOverheadAt(last_xy, @lastOverhead)
		else
			Brew.gameLevel().removeOverheadAt(last_xy)

		Brew.Display.drawMapAt(last_xy)
		@lastOverhead = null

	update: () ->
		# figure out where we are in the path list
		idx = @turn - 1
		# console.log(idx)
		# stop if we've gone over the whole path
		if idx == @full_path_lst.length
			console.log("error, index too high on pathing animation")
			@active = false
			return
		
		next_xy = @full_path_lst[idx]

		# stop when we hit the 'target'
		if idx == @full_path_lst.length - 1
			@active = false
			target = Brew.gameLevel().getMonsterAt(next_xy)
			if target?
				Brew.Combat.attack(@original_attacker, target, false, {remote: @projectile_feature})
				console.log("attacking target at " + next_xy)
		
		# otherwise keep drawing
		else
			overhead = Brew.gameLevel().getOverheadAt(next_xy)
			if overhead?
				@lastOverhead = overhead

			Brew.gameLevel().setOverheadAt(next_xy, @projectile_feature)
			Brew.Display.drawMapAt(next_xy, {over_saturate: @over_saturate})
			# console.log("drawing laser at " + next_xy)

class window.Brew.ThrownEffect extends Brew.Effect
	constructor: (@thrower, @projectile_item, @full_path_lst) ->
		super "effect_thrown"
		@lastOverhead = null

	cleanup: () ->
		# no cleanup on turn 0
		if @turn == 0
			return

		idx = @turn - 1
		if idx >= @full_path_lst.length
			console.log("tried to clean up bad index " + idx)
			return

		last_xy = @full_path_lst[idx]
		if @lastOverhead?
			Brew.gameLevel().setOverheadAt(last_xy, @lastOverhead)
		else
			Brew.gameLevel().removeOverheadAt(last_xy)

		Brew.Display.drawMapAt(last_xy)
		@lastOverhead = null

	update: () ->
		# figure out where we are in the path list
		idx = @turn - 1
		# console.log(idx)
		# stop if we've gone over the whole path
		if idx == @full_path_lst.length
			console.log("error, index too high on pathing animation")
			@active = false
			return
		
		next_xy = @full_path_lst[idx]

		# stop when we hit the 'target'
		if idx == @full_path_lst.length - 1
			@active = false
			# todo: need to check for overwritting existing items
			Brew.gameLevel().setItemAt(next_xy, @projectile_item)
			Brew.Display.drawMapAt(next_xy)
		
		# otherwise keep drawing
		else
			overhead = Brew.gameLevel().getOverheadAt(next_xy)
			if overhead?
				@lastOverhead = overhead

			Brew.gameLevel().setOverheadAt(next_xy, @projectile_item)
			Brew.Display.drawMapAt(next_xy)
			# console.log("drawing laser at " + next_xy)

class window.Brew.RecallEffect extends Brew.ThrownEffect
	update: () ->
		# figure out where we are in the path list
		idx = @turn - 1
		# console.log(idx)
		# stop if we've gone over the whole path
		if idx == @full_path_lst.length
			console.log("error, index too high on pathing animation")
			@active = false
			return
		
		next_xy = @full_path_lst[idx]

		# stop when we hit the 'target'
		if idx == @full_path_lst.length - 1
			@active = false
			Brew.Display.drawMapAt(next_xy)
			Brew.Axe.finishRecallAxe(@projectile_item)

		# otherwise keep drawing
		else
			overhead = Brew.gameLevel().getOverheadAt(next_xy)
			if overhead?
				@lastOverhead = overhead

			m = Brew.gameLevel().getMonsterAt(next_xy)
			if m? and not Brew.utils.compareThing(@thrower, m)
				@recallSmash(m, next_xy)

			Brew.gameLevel().setOverheadAt(next_xy, @projectile_item)
			Brew.Display.drawMapAt(next_xy)

	recallSmash: (target, target_xy) ->
		path_damage = Math.min(Brew.config.max_recall_damage, @full_path_lst.length)
		Brew.Combat.attack(@thrower, target, true, {remote: @projectile_item, recall_damage: path_damage})

			
class window.Brew.ShapeEffect extends Brew.Effect
	constructor: (@center_xy, @max_radius, @shape_color) ->
		super "effect_shape"
		@overhead_cache = {}
		@over_saturate = false
		@animation_speed = 50
		


	cleanup: () ->
		if @turn == 0
			return

		for xy in @getPoints() # called before @turn +1
			cached_overhead = @overhead_cache[xy.toKey()]
			if cached_overhead?
				Brew.gameLevel().setOverheadAt(xy, cached_overhead)
			else
				Brew.gameLevel().removeOverheadAt(xy)

			Brew.Display.drawMapAt(xy)

	update: () ->
		if @turn > @max_radius
			@active = false
			return

		for xy in @getPoints() # called AFTER @turn +1
			# see if anything exists overhead
			existing_overhead = Brew.gameLevel().getOverheadAt(xy)
			
			if existing_overhead? and Brew.utils.compareDef(existing_overhead, "TILE_FLASH")
				continue

			else
				@overhead_cache[xy.toKey()] = existing_overhead # add null/undefined values too for later use
				flash = Brew.featureFactory("TILE_FLASH", {color: @shape_color})
				Brew.gameLevel().setOverheadAt(xy, flash)
				Brew.Display.drawMapAt(xy)

class window.Brew.CircleEffect extends Brew.ShapeEffect
	getPoints: () ->
		circle_lst = Brew.utils.getCirclePoints(@center_xy, @turn)
		points_lst = []
		for xy in circle_lst
			if not Brew.gameLevel().checkValid(xy)
				continue

			# t = level.getTerrainAt(xy)
			# if t.blocks_walking and t.blocks_flying
			# 	continue

			points_lst.push(xy)

		return points_lst

class window.Brew.SquareEffect extends Brew.ShapeEffect
	getPoints: () ->
		corner_xy = @center_xy.subtract(new Coordinate(@turn, @turn))
		length = (@turn * 2) + 1
		rectangle = new Brew.Rectangle(corner_xy.x, corner_xy.y, length, length)
		
		points_lst = []
		for xy in rectangle.getWalls()
			if not Brew.gameLevel().checkValid(xy)
				continue

			# t = level.getTerrainAt(xy)
			# if t.blocks_walking and t.blocks_flying
			# 	continue

			points_lst.push(xy)

		return points_lst

class window.Brew.TauntEffect extends Brew.SquareEffect
	update: () ->
		if @turn > @max_radius
			@active = false
			return

		for xy in @getPoints() # called AFTER @turn +1
			# see if anything exists overhead
			existing_overhead = Brew.gameLevel().getOverheadAt(xy)
			
			if existing_overhead? and Brew.utils.compareDef(existing_overhead, "TILE_FLASH")
				continue

			else
				@overhead_cache[xy.toKey()] = existing_overhead # add null/undefined values too for later use
				flash = Brew.featureFactory("TILE_FLASH", {color: @shape_color})
				Brew.Axe.tauntMonsterAt(xy)
				Brew.gameLevel().setOverheadAt(xy, flash)
				Brew.Display.drawMapAt(xy)

class window.Brew.ShinyEffect extends Brew.Effect
	constructor: (@target_xy, @shine_color) ->
		super "effect_shiny"
		@over_saturate = true
		@overhead_cache = null
		@animation_speed = 100

	cleanup: () ->
		if @turn == 1
			Brew.gameLevel().removeOverheadAt(@target_xy)
			if @overhead_cache?
				Brew.gameLevel().setOverheadAt(@target, @overhead_cache)

	update: () ->
		if @turn == 1
			existing_overhead = Brew.gameLevel().getOverheadAt(@target_xy)
			if existing_overhead?
				@overhead_cache = existing_overhead

			flash = Brew.featureFactory("TILE_FLASH", {color: @shine_color, light_source: @shine_color})
			# monster there?
			m = Brew.gameLevel().getMonsterAt(@target_xy)
			if m?  
				flash.code = m.code
			Brew.gameLevel().setOverheadAt(@target_xy, flash)

		else
			@active = false
