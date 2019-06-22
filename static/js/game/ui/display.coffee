my_display = null # display_info["game"]
my_layer_display = null #display_info["layer"]
my_dialog_display = null #display_info["dialog"]

my_tile_width = null #@my_display.getContainer().width / Brew.panels.full.width
my_tile_height = null # @my_display.getContainer().height / Brew.panels.full.height
my_dialog_tile_width = null
my_dialog_tile_height = null

my_view = new Coordinate(0, 0)
input_handler = null

messagelog = []

panel_offsets = 
	"game": new Coordinate(Brew.panels.game.x, Brew.panels.game.y)
	# "messages": new Coordinate(Brew.panels.messages.x, Brew.panels.messages.y)
	# "footer": new Coordinate(Brew.panels.footer.x, Brew.panels.footer.y)
	"playerinfo": new Coordinate(Brew.panels.playerinfo.x, Brew.panels.playerinfo.y)
	# "viewinfo": new Coordinate(Brew.panels.viewinfo.x, Brew.panels.viewinfo.y)

debug =
	fov: {}
	pathmaps: {}

highlights = {}

window.Brew.Display =
	init: (display_info) ->
		# save displays object refs 
		my_display = display_info["game"]
		my_layer_display = display_info["layer"]
		my_dialog_display = display_info["dialog"]

		my_tile_width = my_display.getContainer().width / Brew.panels.full.width
		my_tile_height = my_display.getContainer().height / Brew.panels.full.height

		my_dialog_tile_width = my_dialog_display.getContainer().width / Brew.config.dialog_display.width
		my_dialog_tile_height = my_dialog_display.getContainer().height / Brew.config.dialog_display.height

		# wait a bit to initialize the layer display
		setTimeout(=> 
			initLayerDisplay()
			initDialogDisplay()
		, 30)

	dialogDisplay: () ->
		return my_dialog_display

	layerDisplay: () ->
		return my_layer_display

	gameDisplay: () ->
		return my_display

	debug: {}

	# ------------------------------------------------------------
	# highlights
	# ------------------------------------------------------------
	getHighlightAt: (xy) ->
		return highlights[xy.toKey()] ? null

	clearHighlightAt: (xy) ->
		delete highlights[xy.toKey()]
		return true

	setHighlightAt: (xy, color) ->
		highlights[xy.toKey()] = color
		return true

	clearHighlights: () ->
		highlights = {}
		return true

	# ------------------------------------------------------------
	# utils
	# ------------------------------------------------------------

	appendBlanksToString: (text, max_length) ->
		black_hex = ROT.Color.toHex(Brew.colors.black)

		num_spaces = max_length - text.length
		spaces = ("_" for i in [0..num_spaces]).join("")
		
		return text+"%c{#{black_hex}}#{spaces}"

	# ------------------------------------------------------------
	# Coordinate mapping stuff
	# ------------------------------------------------------------

	screenToMap: (screen_xy) ->
		# take a screen coord from the full canvas and convert it to a map coord
		if Brew.Display.getPanelAt(screen_xy) != "game"
			return null
		else
			map_xy = screen_xy.subtract(panel_offsets["game"]).add(my_view)
			return map_xy

	mapToScreen: (map_xy) ->
		# take a map coordinate and transfer it to a full grid xy
		screen_xy = map_xy.subtract(my_view).add(panel_offsets["game"])
		if Brew.Display.getPanelAt(screen_xy) != "game"
			return null
		else
			return screen_xy
	
	gameToDialog: (game_xy) ->
		# takes a game screen coordinate and converts to a coordinate on the (larger) dialog display
		dx = Math.floor(game_xy.x * Brew.config.dialog_display.xconvert)
		dy = Math.floor(game_xy.y * Brew.config.dialog_display.yconvert)
		return new Coordinate(dx, dy)

	# ------------------------------------------------------------
	# transparency
	# ------------------------------------------------------------

	setDialogDisplayTransparency: (alpha) ->
		my_dialog_display._context.globalAlpha = alpha
	
	resetDialogDisplayTransparency: () ->
		my_dialog_display._context.globalAlpha = 1

	# ------------------------------------------------------------
	# Drawing 
	# ------------------------------------------------------------

	drawDisplayAll: (options) ->
		@clearLayerDisplay()

		@drawGamePanel(options)
		@drawPlayerInfoPanel()
		@drawOnScreenInfo()
		# @drawMessagesPanel()
		# @drawFooterPanel()
		
		# @drawViewInfoPanel()

	drawOnPanel: (panel_name, x, y, code, forecolor, bgcolor) ->
		panel_x = panel_offsets[panel_name].x + x
		panel_y = panel_offsets[panel_name].y + y
		my_display.draw(panel_x, panel_y, code, forecolor, bgcolor)
		true

	drawTextOnPanel: (panel_name, x, y, text, max_width) ->
		panel_x = panel_offsets[panel_name].x + x
		panel_y = panel_offsets[panel_name].y + y
		my_display.drawText(panel_x, panel_y, text, max_width)
		true

	drawSeparatedBarOnPanel: (panel_name, start_x, start_y, max_tiles, current_amount, max_amount, full_color) ->
		black_hex = ROT.Color.toHex(Brew.colors.black)

		raw_num_bars = Math.min(1.0, current_amount / max_amount) * max_tiles
		num_bars = Math.ceil(raw_num_bars)
		remainder = num_bars - raw_num_bars
		code = null

		for i in [0..max_tiles-1]
			if i == num_bars - 1
				if remainder < 0.25
					code = Brew.unicode.block_full
				else if remainder < 0.5
					code = Brew.unicode.block_threequarter
				else if remainder < 0.75
					code = Brew.unicode.block_half
				else
					code = Brew.unicode.block_quarter					

				
				@drawOnPanel(panel_name, start_x + i, start_y, code, ROT.Color.toHex(full_color))

			else if i < num_bars
				code = Brew.unicode.block_full
				@drawOnPanel(panel_name, start_x + i, start_y, code, ROT.Color.toHex(full_color))

			else
				@drawOnPanel(panel_name, start_x + i, start_y, " ", black_hex)

	drawBarOnPanel: (panel_name, start_x, start_y, max_tiles, current_amount, max_amount, full_color) ->
		black_hex = ROT.Color.toHex(Brew.colors.black)

		raw_num_bars = Math.min(1.0, current_amount / max_amount) * max_tiles
		num_bars = Math.ceil(raw_num_bars)
		remainder = num_bars - raw_num_bars
		tile = null

		for i in [0..max_tiles-1]
			if i == num_bars - 1
				if remainder < 0.25
					fadecolor = full_color
				else if remainder < 0.5
					fadecolor = ROT.Color.interpolate(full_color, Brew.colors.normal, 0.25)
				else if remainder < 0.75
					fadecolor = ROT.Color.interpolate(full_color, Brew.colors.normal, 0.5)
				else
					fadecolor = ROT.Color.interpolate(full_color, Brew.colors.normal, 0.75)

				@drawOnPanel(panel_name, start_x + i, start_y, " ", "white", ROT.Color.toHex(full_color))

			else if i < num_bars
				@drawOnPanel(panel_name, start_x + i, start_y, " ", "white", ROT.Color.toHex(full_color))

			else
				@drawOnPanel(panel_name, start_x + i, start_y, " ", "white", ROT.Color.toHex(Brew.colors.normal))

		violet_rgb = ROT.Color.toHex(full_color)
		@drawTextOnPanel(panel_name, start_x + max_tiles + 1, start_y, "%c{#{violet_rgb}}#{current_amount}%c{#{black_hex}}_")

	drawTextBarOnPanel: (panel_name, start_x, start_y, max_tiles, current_amount, max_amount, full_color, text) ->
		black_hex = ROT.Color.toHex(Brew.colors.black)

		raw_num_bars = Math.min(1.0, current_amount / max_amount) * max_tiles
		num_bars = Math.ceil(raw_num_bars)
		remainder = num_bars - raw_num_bars
		tile = null

		for i in [0..max_tiles-1]
			if i < text.length
				text_char = text[i]
			else
				text_char = " "

			if i < num_bars
				@drawOnPanel(panel_name, start_x + i, start_y, text_char, "white", ROT.Color.toHex(full_color))

			else
				@drawOnPanel(panel_name, start_x + i, start_y, text_char, "white", ROT.Color.toHex(Brew.colors.normal))

		full_rgb = ROT.Color.toHex(full_color)
		@drawTextOnPanel(panel_name, start_x + max_tiles + 1, start_y, "%c{#{full_rgb}}#{current_amount}%c{#{black_hex}}_")

	# ------------------------------------------------------------
	# figure out which panel we're in
	# ------------------------------------------------------------
	getPanelAt: (xy) ->
		# given a SCREEN XY (full screen), determine which panel we're clicking on
		panel_name = "dunno"

		if xy.y < Brew.panels.game.height
			panel_name = "game"
		else
			panel_name = "playerinfo"

		return panel_name

	# ------------------------------------------------------------
	# draw game
	# ------------------------------------------------------------

	centerViewOnPlayer: () ->
		if Brew.gameLevel().width <= Brew.panels.game.width and Brew.gameLevel().height <= Brew.panels.game.height
			return
			
		half_x = (my_display.getOptions().width / 2)
		half_y = (my_display.getOptions().height / 2)
		
		view_x = Math.min(Math.max(0, Brew.gamePlayer().coordinates.x - half_x), Brew.gameLevel().width - Brew.panels.game.width)
		view_y = Math.min(Math.max(0, Brew.gamePlayer().coordinates.y - half_y), Brew.gameLevel().height - Brew.panels.game.height)
		
		my_view = new Coordinate(view_x, view_y)
		
	drawGamePanel: (options) ->
		for row_y in [Brew.panels.game.y..Brew.panels.game.y+Brew.panels.game.height-1]
			for col_x in [Brew.panels.game.x..Brew.panels.game.x+Brew.panels.game.width-1]
				screen_xy = new Coordinate(col_x, row_y)
				# console.log("called from drawGamePanel")
				Brew.Display.drawGamePanelAt(screen_xy, null, options)

	drawMapAtList: (map_xy_list, options) ->
		for map_xy in map_xy_list
			if Brew.gameLevel().checkValid(map_xy)
				# todo: figure out why this (updatelightmap?) returns so many bad coords
				Brew.Display.drawMapAt(map_xy, options)

	drawMapAt: (map_xy, options) ->
		screen_xy = Brew.Display.mapToScreen(map_xy)
		if screen_xy?
			# console.log("called from drawMapAt")
			Brew.Display.drawGamePanelAt(screen_xy, null, options)
		
	drawGamePanelAt: (xy, map_xy, options) ->
		options ?= {}
		color_mod = options?.color_mod ? [0, 0, 0]
		over_saturate = options?.over_saturate ? false
		# over_saturate = true

		map_xy = Brew.Display.screenToMap(xy)
		if not map_xy?
			console.log(xy)
			return

		if not Brew.gameLevel().checkValid(map_xy)
			console.error(map_xy)
			return
			
		# debug: draw pathmaps
		if Brew.Debug.pathmaps.index?
			[map_title, pathmap] = Brew.Debug.pathmaps.list[Brew.Debug.pathmaps.index]
			map_val = pathmap[map_xy.toKey()]
			
			if map_val == MAX_INT
				return
			else if map_val < 0
				c = Math.round(255 * (map_val / pathmap.min_value), 0)
			else
				c = Math.round(255 * (1 - (map_val / pathmap.max_value)), 0)

			r = if map_val == 0 then 255 else 0
			
			my_display.draw(xy.x, xy.y, " ", 'black', ROT.Color.toHex([r, c, c]))
			return
			
		in_view = Brew.gamePlayer().canView(map_xy)
		lighted = Brew.gameLevel().getLightAt(map_xy)

		# debug: show monster views
		if debug.fov.monster?
			in_view = debug.fov.monster.canView(map_xy)
			lighted = Brew.colors.light_blue
		
		map_key = map_xy.toKey()
		if Brew.Game.dummy_fov? and Brew.Game.dummy_fov.fov[map_key]? and Brew.Game.dummy_fov.fov[map_key]
			lighted = Brew.colors.monster_fov



		memory = Brew.gamePlayer().getMemoryAt(Brew.gameLevel().id, map_xy)
		terrain = Brew.gameLevel().getTerrainAt(map_xy)
		feature = Brew.gameLevel().getFeatureAt(map_xy)
		overhead = Brew.gameLevel().getOverheadAt(map_xy)
		fromMemory = false

		draw = []
		prelighting_draw = [null, null, null]
		is_lit = lighted? or (debug_monster_fov == true)
		can_view_and_lit = (in_view and is_lit) or map_xy.compare(Brew.gamePlayer().coordinates)
		

		Brew.Display.clearDisplayAt(my_layer_display, xy)

		# not in FOV, or in FOV but not sufficiently lit
		if not can_view_and_lit
			
			if not memory?
				draw = [" ", Brew.colors.black, Brew.colors.black]

			else
				fromMemory = true
				draw = [memory.code, Brew.colors.memory, Brew.colors.memory_bg]
			
		# in FOV and lit
		else
			
			if not terrain?
				debugger
				
			item = Brew.gameLevel().getItemAt(map_xy)
			monster = Brew.gameLevel().getMonsterAt(map_xy)
			
			if monster?
				Brew.gamePlayer().setMemoryAt(Brew.gameLevel().id, map_xy, terrain)  # remember what the monster was standing on

				if monster.hasFlag(Brew.flags.on_fire.id)
					mob_color = Brew.colors.hf_orange
				else if monster.hasFlag(Brew.flags.is_stunned.id)
					mob_color = Brew.colors.light_blue
				else if monster.hasFlag(Brew.flags.poisoned.id)
					mob_color = Brew.colors.dark_green
				else if monster.hasFlag(Brew.flags.is_shielded.id)
					mob_color = Brew.colors.green

				else
					mob_color = terrain.bgcolor
				draw = [monster.code, monster.color, mob_color]

			else if item?
				Brew.gamePlayer().setMemoryAt(Brew.gameLevel().id, map_xy, item)
				item_color = Brew.Catalog.getItemColor(item)

				draw = [item.code, item_color, terrain.bgcolor]
				
			else
				Brew.gamePlayer().setMemoryAt(Brew.gameLevel().id, map_xy, terrain)
				draw = [terrain.code, terrain.color, terrain.bgcolor]
				
				# combine terrain and features that modify terrain
				if feature? and feature.code?
					draw[0] = feature.code

				# features should modify fore or back color but not both
				if feature? and feature.color?
					draw[1] = ROT.Color.interpolate(terrain.color, feature.color, feature.intensity)

				else if feature? and feature.bgcolor?
					draw[2] = ROT.Color.interpolate(terrain.bgcolor, feature.bgcolor, feature.intensity)

			# overtop layer features
			if overhead?
				# console.log(xy)
				my_layer_display.draw(xy.x, xy.y, overhead.code, ROT.Color.toHex(overhead.color))

			# apply lighting
			prelighting_draw = draw[..]
			if over_saturate
				draw[1] = ROT.Color.multiply(lighted, draw[1])
				draw[2] = ROT.Color.multiply(lighted, draw[2])
			else
				draw[1] = Brew.utils.minColorRGB(ROT.Color.multiply(lighted, draw[1]), draw[1])
				draw[2] = Brew.utils.minColorRGB(ROT.Color.multiply(lighted, draw[2]), draw[2])

		# apply override (when map is shown behind inventory screen, etc)
		if options?.color_override?
			draw[1] = options.color_override
			draw[2] = Brew.colors.black

		h = Brew.Display.getHighlightAt(map_xy)
		if h?
			draw[2] = h
			
		my_display.draw(xy.x, xy.y, draw[0], ROT.Color.toHex(draw[1]), ROT.Color.toHex(draw[2]))

	# ------------------------------------------------------------
	# draw HUD / playerinfo
	# ------------------------------------------------------------
	
	drawHudAll: () ->
		Brew.Display.drawPlayerInfoPanel()
		# @drawViewInfoPanel()
		true

	drawPlayerInfoPanel: () ->
		# redraw the HUD
		black_hex = ROT.Color.toHex(Brew.colors.black)

		player = Brew.gamePlayer()
		
		# stamina
		row = 0
		maxstamina = player.getStat(Brew.stat.stamina).getMax()
		stamina = player.getStat(Brew.stat.stamina).getCurrent()
		for i in [1..maxstamina]
			color = if (i <= stamina) then Brew.colors.stamina else Brew.colors.normal
			@drawOnPanel("playerinfo", i-1, row, Brew.unicode.block_full, ROT.Color.toHex(color))

		# axe equipped?
		axe_col = 7
		equipped = player.inventory.getEquipped(Brew.equip_slot.melee)
		if equipped?
			@drawOnPanel("playerinfo", axe_col, row, equipped.code, ROT.Color.toHex(equipped.color))
		else
			@drawOnPanel("playerinfo", axe_col, row, "_", black_hex)

		# health
		row = 0
		maxhp = player.getStat(Brew.stat.health).getMax()
		hp = player.getStat(Brew.stat.health).getCurrent()
		for i in [1..maxhp]
			if player.hasFlag(Brew.flags.is_shielded.id)
				color = Brew.colors.player_shield
			else
				color = if (i <= hp) then Brew.colors.health else Brew.colors.normal
			offset = Brew.panels.playerinfo.width - maxhp + i - 1
			@drawOnPanel("playerinfo", offset, row, Brew.unicode.heart, ROT.Color.toHex(color))

		
		row += 1
		# turn count
		turn_str = String(Brew.Game.turn)
		for i in [0..turn_str.length-1]
			offset = Brew.panels.playerinfo.width - turn_str.length + i
			@drawOnPanel("playerinfo", offset, row, turn_str[i], ROT.Color.toHex(Brew.colors.white))

		# doom
		maxdoom = player.getStat(Brew.stat.doom).getMax()
		doom = player.getStat(Brew.stat.doom).getCurrent()
		# (panel_name, start_x, start_y, max_tiles, current_amount, max_amount, full_color
		Brew.Display.drawSeparatedBarOnPanel("playerinfo", 0, row, 6, doom, maxdoom, Brew.colors.blood)

		# ammo ?
		# max_ammo = 3
		# if player.hasFlag(Brew.flags.conjure_lightning.id)
		# 	ammo = player.getStat(Brew.stat.ammo)
		# 	for i in [0..ammo-1]
				


	# ------------------------------------------------------------
	# Message Log
	# ------------------------------------------------------------
	addMessage: (text, turncount) ->
		messagelog.push([text, turncount])
		true

	drawMessagesPanel: () ->
		return true
		# for i in [0..2]
		# 	message = @messagelog[@messagelog.length-3+i]
		# 	if message?
		# 		@drawTextOnPanel("messages", 0, i, @appendBlanksToString(message[0], Brew.panels.messages.width - 1))

	# ------------------------------------------------------------
	# Footer
	# ------------------------------------------------------------
	updateTerrainFooter: (old_xy, new_xy) ->
		# called whenever the player moves to a new tile

		message = ""

		i = Brew.gameLevel().getItemAt(new_xy)
		# f = Brew.gameLevel().getFeatureAt(new_xy)
		old_t = Brew.gameLevel().getTerrainAt(old_xy)
		new_t = Brew.gameLevel().getTerrainAt(new_xy)

		if i?
			article = Brew.Catalog.getArticleForItem(i)
			message = "There is #{article}#{Brew.Catalog.getItemName(i)} here. (SPACE to pick up)"

		else if (not Brew.utils.sameDef(old_t, new_t)) and new_t.walkover?
			message = new_t.walkover

		if message != ""
			@drawFooterPanel(message)

	drawFooterPanel: (message) ->
		return true
		# @drawTextOnPanel("footer", 0, 0, @appendBlanksToString(message, Brew.panels.footer.width - 1))

	drawOnScreenInfo: () ->
		player = Brew.gamePlayer()
		level = Brew.gameLevel()
		
		onscreen_html = ""

		# level (sigh)
		onscreen_html += "<p><span style='color: yellow'>Temple level #{Brew.gameLevel().depth+1} of #{Brew.config.max_depth}</p>"
		
		# # inventory (sigh)
		# onscreen_html += "<p><strong>Inventory</strong></p>"
		# for item in player.inventory.getItems()
		# 	item_hex_color = ROT.Color.toHex(Brew.Catalog.getItemColor(item))
		# 	onscreen_html += "<p>(#{item.inv_key}) <span style='color: #{item_hex_color}'>#{item.code}</span> - #{Brew.Catalog.getItemName(item)}</p>"

		# scroll stack
		onscreen_html += "<p><strong>Inventory</strong></p>"
		i = 1
		for scroll_type, scroll_item_list of Brew.Axe.getScrollStack()
			if scroll_item_list.length == 0
				code_hex_color = ROT.Color.toHex(Brew.colors.half_white)
				count_hex_color = ROT.Color.toHex(Brew.colors.half_white)
			else
			 	code_hex_color = ROT.Color.toHex(Brew.Catalog.getItemColor(scroll_item_list[0]))
			 	count_hex_color = ROT.Color.toHex(Brew.colors.white)

			onscreen_html += "<p>[#{i}] <span style='color: #{code_hex_color}'>#{Brew.group.scroll.code}</span> <span style='color: #{count_hex_color}'>#{scroll_item_list.length}</span> #{Brew.ItemType.type_of.scroll[scroll_type].real_name} </p>"
			i += 1


		onscreen_html += "<br/>"
		onscreen_html += "<p><strong>In View</strong></p>"
		net_items = {}
		for item in level.getItems()
			if player.hasKnowledgeOf(item) or item.coordinates.compare(player.coordinates)
				net_items[item.def_id] = item

		for own def_id, item of net_items
			item_hex_color = ROT.Color.toHex(Brew.Catalog.getItemColor(item))
			onscreen_html += "<p><span style='color: #{item_hex_color}'>#{item.code}</span> - #{Brew.Catalog.getItemName(item)}</p>"

		onscreen_html += "<br/>"
		net_monsters = {}
		for mob in level.getMonsters()
			if Brew.utils.compareThing(mob, player)
				continue

			if player.hasKnowledgeOf(mob)
				net_monsters[mob.def_id] = mob

		for own def_id, mob of net_monsters
			mob_hex_color = ROT.Color.toHex(mob.color)
			onscreen_html += "<p><span style='color: #{mob_hex_color}'>#{mob.code}</span> - #{mob.name}"
			onscreen_html += " (#{mob.getStat(Brew.stat.health).getMax()}: <span style='color: red'>" + (Brew.unicode.heart for i in [1..mob.getStat(Brew.stat.health).getMax()]).join("") + "</span>)"
			onscreen_html += "</p>"
			onscreen_html += "<p>#{mob.description}</p>"
			flag_list = []
			for flag in mob.getFlags()
				flag_list.push(Brew.flags[flag].desc_enemy)

			flag_text = flag_list.join(", ")
			onscreen_html += "<p>#{flag_text}</p>"
			onscreen_html += "<br/>"

		if level.exit_xy? and Brew.utils.isTerrain(level.getTerrainAt(level.exit_xy), "STAIRS_DOWN")
			terrain_hex_color = ROT.Color.toHex(level.getTerrainAt(level.exit_xy).color)
			onscreen_html += "<p><span style='color: #{terrain_hex_color}'>#{level.getTerrainAt(level.exit_xy).code}</span> - Level Exit</p>"

		$("#id_div_onscreeninfo").html(onscreen_html)
		return true

	# getMouseoverDescriptionForFooter: (look_xy) ->
		
	# 	in_view = Brew.gamePlayer().canView(look_xy)
	# 	lighted = Brew.gameLevel().getLightAt(look_xy)

	# 	t = Brew.gameLevel().getTerrainAt(look_xy)
	# 	f = Brew.gameLevel().getFeatureAt(look_xy)
	# 	i = Brew.gameLevel().getItemAt(look_xy)
	# 	m = Brew.gameLevel().getMonsterAt(look_xy)
	# 	memory = Brew.gamePlayer().getMemoryAt(Brew.gameLevel().id, look_xy)

	# 	is_lit = lighted?
	# 	can_view_and_lit = (in_view and is_lit) or look_xy.compare(Brew.gamePlayer().coordinates)

	# 	if not can_view_and_lit
	# 		if memory?
	# 			tap = null
	# 			if memory.objtype == "item"
	# 				tap = "#{@getArticleForItem(memory)}#{memory.name}"
	# 			else
	# 				tap = if memory.description? then memory.description else memory.name.toLowerCase()
	# 			message = "You remember seeing #{tap} there"
	# 		else
	# 			message = "You don't see anything"
	# 	else
	# 		t_desc = if t.description? then t.description else t.name.toLowerCase()
	# 		if m? and Brew.utils.compareThing(m, Brew.gamePlayer())
	# 			message = "You are standing on #{t_desc}"
	# 		else if m?
	# 			message = "#{m.name}"

	# 		else if i?
	# 			message = "You see #{@getArticleForItem(i)}#{Brew.Catalog.getItemName(i)}"

	# 		else
	# 			message = "You see #{t_desc}"

	# 	return message

	# ------------------------------------------------------------
	# clear displays
	# ------------------------------------------------------------

	clearDisplay: (display) ->
		# rot.js should have a way to do this :(
		# display._backend._context.clearRect(0, 0, display.getContainer().width, display.getContainer().height)
		display._context.clearRect(0, 0, display.getContainer().width, display.getContainer().height)
		# display.clear()

	clearLayerDisplay: () ->
		Brew.Display.clearDisplay(my_layer_display)
	
	clearDialogDisplay: () ->
		Brew.Display.clearDisplay(my_dialog_display)

	clearDisplayAt: (display, xy) ->
		# rot.js should have a way to do this :(
		x = xy.x * my_tile_width
		y = xy.y * my_tile_height
		# display._backend._context.clearRect(x, y, @my_tile_width, @my_tile_height)
		# console.log(x, y, my_tile_width, my_tile_height)
		display._context.clearRect(x, y, my_tile_width, my_tile_height)

	# clearDialogDisplayAt: (xy) ->
	# 	# need to scale map/screen XY to dialog display
	# 	dialog_xy = @gameToDialog(xy)
	# 	Brew.Display.clearDisplayAt(my_dialog_display, dialog_xy)

	# ------------------------------------------------------------
	# on-screen pop-up speech bubbles
	# ------------------------------------------------------------

	showFloatingTextAbove: (loc_xy, msg, color_rgb) ->
		color_rgb ?= Brew.colors.white
		above_xy = if loc_xy.y == 0 then loc_xy.add(new Coordinate(0, 1)) else loc_xy.subtract(new Coordinate(0, 1))
		
		# if we're on top of the player, pick a new coordinate
		if above_xy.compare(Brew.gamePlayer().coordinates)
			for xy in above_xy.getAdjacent()
				if Brew.gameLevel().checkValid(xy)
					above_xy = xy
					break

		return Brew.Display.showFloatingText(above_xy, msg, color_rgb)

	showFloatingText: (loc_xy, msg, color_rgb) ->
		color_rgb ?= Brew.colors.white
		color_hex = ROT.Color.toHex(color_rgb)

		# scale the 'above_xy' to show in the proper place on the dialog display
		dialog_xy = @gameToDialog(loc_xy)
		# console.log(loc_xy, dialog_xy)

		far_right = dialog_xy.x + msg.length
		if far_right >= Brew.config.dialog_display.width
			offset = far_right - Brew.config.dialog_display.width
			dialog_xy = dialog_xy.subtract(new Coordinate(offset, 0))

		my_dialog_display.drawText(dialog_xy.x, dialog_xy.y, "%c{#{color_hex}}#{msg}")
		x = dialog_xy.x * my_dialog_tile_width
		y = dialog_xy.y * my_dialog_tile_height

		setTimeout(=>
			# console.log("cleared it", x, y)
			my_dialog_display._context.clearRect(x, y, my_dialog_tile_width * msg.length, my_dialog_tile_height  * 2)
			# @clearDialogDisplayAt()

		Brew.config.floating_text_timeout)		

# ------------------------------------------------------------
# private functions
# ------------------------------------------------------------

# ------------------------------------------------------------
# generic display code pop-up menus and layers
# ------------------------------------------------------------

initLayerDisplay = () ->
	pos = $(my_display.getContainer()).position()
	
	$("#id_div_layer").css({
		position: "absolute",
		top: pos.top,
		left: pos.left
	})
	
	Brew.Display.clearLayerDisplay()
	$("#id_div_layer").show()

initDialogDisplay = () ->
	pos = $(my_display.getContainer()).position()
	
	$("#id_div_dialog").css({
		position: "absolute",
		top: pos.top,
		left: pos.left
	})
	
	Brew.Display.clearDialogDisplay()
	$("#id_div_dialog").show()


