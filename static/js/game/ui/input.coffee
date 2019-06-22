# keyboard and mouse (touch) input functions

# this is the main "switchboard" for the game, menus, targeting, etc
input_handler = null 
last_input_type = null

window.Brew.Input =
	setInputHandler: (new_handler) ->
		input_handler = new_handler
		return true

	getInputHandler: () ->
		return input_handler
		
	clearInputHandler: () ->
		input_handler = null
		return true

	getLastInputType: () ->
		return last_input_type

	keypress: (e) ->
		last_input_type = Brew.input_type.keyboard
		ui_keycode = e.keyCode 
		shift_key = e.shiftKey
		@keypress_key(ui_keycode, shift_key)

	keypress_key: (ui_keycode, shift_key) ->

		if Brew.Game.hasAnimations()
			console.log("ignoring input while animations finish their thing")
			
		else

			if not input_handler
				inputGameplay(ui_keycode, shift_key)
			else if input_handler == "inventory"
				inputInventory(ui_keycode)
			else if input_handler == "popup_to_dismiss"
				inputPopupToDismiss(ui_keycode)
			else if input_handler == "died"
				inputDied(ui_keycode, shift_key)
			else if input_handler == "victory"
				inputVictory(ui_keycode, shift_key)
			# else if input_handler == "targeting"
			# 	inputTargeting(ui_keycode, shift_key)
			else if input_handler == "recall"
				inputRecall(ui_keycode, shift_key)

	# ------------------------------------------------------------
	# MOUSE input
	# ------------------------------------------------------------

	mouseDown: (grid_obj_xy, button, shift_key) ->
		last_input_type = Brew.input_type.mouse
		grid_xy = new Coordinate(grid_obj_xy.x, grid_obj_xy.y)
		map_xy = Brew.Display.screenToMap(grid_xy)

		if shift_key
			# debug: add monster
			Brew.Game.debugClick(map_xy)
		else if input_handler == "targeting"
			inputTargeting(ROT.VK_SPACE)
		else
			if button != 0 or (shift_key? and shift_key)
				playerMouseAltClick(map_xy)
			else
				playerMouseClick(map_xy)

	mouseLongClick: (grid_obj_xy, button, shift_key) ->
		last_input_type = Brew.input_type.mouse
		grid_xy = new Coordinate(grid_obj_xy.x, grid_obj_xy.y)
		map_xy = Brew.Display.screenToMap(grid_xy)
		playerMouseAltClick(map_xy)

	mouseGainFocus: (grid_obj_xy) ->
		grid_xy = new Coordinate(grid_obj_xy.x, grid_obj_xy.y)

		# ignore any mouse movement outside main game screen -- for now
		if Brew.Display.getPanelAt(grid_xy) != "game"
			return

		map_xy = Brew.Display.screenToMap(grid_xy)
		$("#id_div_coord_debug").html("<p>(#{map_xy.x}, #{map_xy.y})</p>")
		# handle special case for targetting mode
		if input_handler == "targeting"
			Brew.Targeting.updateAndDrawTargeting(map_xy)

		# normal case - follow mouse around with a border
		# only update mouse-over when not in a dialog menu
		else if input_handler == null
			grid_manager.drawBorderAt(grid_obj_xy, 'white')
			
			# @drawFooterPanel(@getMouseoverDescriptionForFooter(map_xy))

			# if Brew.Game.my_player.active_ability?
			# 	if Brew.Game.abil.checkUseAt(Brew.Game.my_player.active_ability, map_xy)
			# 		# draw[2] = ROT.Color.add(draw[2], [0, 50, 0])
			# 		# grid_manager.drawBorderAt(grid_obj_xy, 'green')
			# 		@highlights[map_xy.toKey()] = Brew.colors.green
			# 		@drawMapAt(map_xy)
		
	mouseLeaveFocus: (grid_obj_xy) ->
		# only update mouse-over when not in a dialog menu

		if input_handler == null
			grid_xy = new Coordinate(grid_obj_xy.x, grid_obj_xy.y)
			if Brew.Display.getPanelAt(grid_xy) != "game"
				return

			map_xy = Brew.Display.screenToMap(grid_xy)
			Brew.Display.drawMapAt(map_xy)

	# ------------------------------------------------------------
	# GAMEPAD input
	# ------------------------------------------------------------
	gamepadInput: (button) ->
		last_input_type = Brew.input_type.gamepad

		if button == Brew.GamepadMap.BUTTON_UP
			@keypress_key(Brew.keymap.MOVE_UP[0])
		else if button == Brew.GamepadMap.BUTTON_DOWN
			@keypress_key(Brew.keymap.MOVE_DOWN[0])
		else if button == Brew.GamepadMap.BUTTON_RIGHT
			@keypress_key(Brew.keymap.MOVE_RIGHT[0])
		else if button == Brew.GamepadMap.BUTTON_LEFT
			@keypress_key(Brew.keymap.MOVE_LEFT[0])
		else if button == Brew.GamepadMap.BUTTON_A
			@keypress_key(Brew.keymap.GENERIC_ACTION[0])
		else if button == Brew.GamepadMap.BUTTON_B
			@keypress_key(Brew.keymap.DROP[0])
		else if button == Brew.GamepadMap.BUTTON_X
			@keypress_key(Brew.keymap.INVENTORY[0])

		else
			console.log("that button doesnt do anythign")


# ------------------------------------------------------------
# private input handler functions 
# (external code should only need to call main 'keypress' function ?
# ------------------------------------------------------------


inputGameplay = (keycode, shift_key) ->

	# movement keys
	if keycode in Brew.keymap.MOVEKEYS
		offset_xy = Brew.utils.getOffsetFromKey(keycode)
		Brew.Game.movePlayer(offset_xy)	

	# DO ACTION: space, etc
	else if keycode in Brew.keymap.GENERIC_ACTION
		Brew.Axe.doPlayerAction()
		
	# drop
	else if keycode in Brew.keymap.DROP
		# Brew.Menu.popup.context = "drop"
		# Brew.Menu.showInventory()
		Brew.Axe.doPlayerDropAxe()
	
	# i : inv
	else if keycode in Brew.keymap.INVENTORY
		Brew.Menu.showInventory()
		
	# toggle pathmaps debug
	else if keycode == 220 # \ |
		Brew.Debug.debugPathMaps()
	
	# # / : toggle FOV debug
	# else if keycode == 191 
	# 	@debugMonsterFov()

	# else if keycode == 191 # / ? help
	else if keycode in Brew.keymap.HELP
		@showHelp()

	# else if keycode == 192 ## back tick `
	else if keycode in Brew.keymap.DEBUG
		Brew.Debug.debugAtCoords()

	# # 1 - 9
	# else if keycode in [49, 50, 51, 52, 53, 54]
	# else if keycode in Brew.keymap.ABILITY_HOTKEY
	else if keycode in [49..57]
		Brew.Axe.doPlayerSelectInventoryHotKey(keycode)

	# else if keycode in Brew.keymap.STAIRS_DOWN
	# 	@drawHighlightStairs("exit")

	# else if keycode in Brew.keymap.STAIRS_UP
	# 	@drawHighlightStairs("entrance")

inputInventory = (keycode) ->	
	if keycode in Brew.keymap.MOVE_LEFT
		Brew.Menu.popup.inventory.prev()
		Brew.Menu.showInventory()

	else if keycode in Brew.keymap.MOVE_RIGHT
		Brew.Menu.popup.inventory.next()
		Brew.Menu.showInventory()

	else if keycode in Brew.keymap.GENERIC_ACTION
		item = Brew.Menu.popup.inventory.getExampleOfCurrent()
		clearMenuAndInputHandler()
		Brew.Game.doPlayerApply(item)

	else if keycode in Brew.keymap.MOVE_UP
		;
	else if keycode in Brew.keymap.MOVE_DOWN
		;
	else
		clearMenuAndInputHandler()

inputRecall = (keycode) ->
	if keycode in Brew.keymap.MOVE_LEFT
		Brew.Menu.popup.recall.prev()
		Brew.Menu.showRecall()

	else if keycode in Brew.keymap.MOVE_RIGHT
		Brew.Menu.popup.recall.next()
		Brew.Menu.showRecall()

	else if keycode in Brew.keymap.GENERIC_ACTION
		path = Brew.Menu.popup.recall.getCurrentPath()
		axe_xy = clone(Brew.Menu.popup.axe_xy)
		clearMenuAndInputHandler()
		Brew.Axe.doRecallAxeWithPath(path, axe_xy)

	else if keycode in Brew.keymap.MOVE_UP
		;
	else if keycode in Brew.keymap.MOVE_DOWN
		;
	else
		clearMenuAndInputHandler()

	
inputSpaceToDismiss = (keycode) ->
	# space : dismiss
	if keycode in [32, 13, 27]
		# go back to the game
		clearMenuAndInputHandler()

inputPopupToDismiss = (keycode) ->
	# any key to dismiss
	clearMenuAndInputHandler()

inputDied = (keycode) ->
	# enter: new game
	if keycode == 13
		$("#id_div_popup").hide()
		clearMenuAndInputHandler()
		# Brew.Game.restart()
		window.location.replace("/")

	# esc: return to menu
	else if keycode == 27
		$("#id_div_popup").hide()
		clearMenuAndInputHandler()
		window.location.replace("/")

inputTargeting = (keycode, shift_key) ->
	console.log("input targeting")
	popup_xy = clone(Brew.Menu.popup.xy)

	# movement keys
	if keycode in Brew.keymap.MOVEKEYS
		offset_xy = Brew.utils.getOffsetFromKey(keycode)
		target_xy = popup_xy.add(offset_xy)
		Brew.Menu.popup.target_index = -1 # break current target index ordering
		Brew.Targeting.updateAndDrawTargeting(target_xy)

	# DO ACTION: space, NUMPAD 0
	else if keycode in Brew.keymap.GENERIC_ACTION #or (Brew.Menu.popup.ability? and keycode == Brew.Menu.popup.keycode)
		if not Brew.Menu.popup.is_ok
			Brew.msg(Brew.Menu.popup.err_msg)

		else
			input_handler = null
			Brew.Display.clearHighlights()
			Brew.Display.drawDisplayAll()
		
			Brew.Game.doTargetingAt(Brew.Menu.popup.target_context, Brew.Menu.popup.item ? Brew.Menu.popup.power, Brew.Menu.popup.xy)
			
			Brew.Menu.popup = {}		

	# cancel
	else if keycode in Brew.keymap.EXIT_OR_CANCEL
		clearMenuAndInputHandler()

	else if keycode in Brew.keymap.CYCLE_TARGET
		if Brew.Menu.popup.target_index == -1
			Brew.Menu.popup.target_index = 0
		else
			Brew.Menu.popup.target_index = (Brew.Menu.popup.target_index + 1).mod(Brew.Menu.popup.targets.length)

		Brew.Targeting.updateAndDrawTargeting(Brew.Menu.popup.targets[Brew.Menu.popup.target_index].coordinates)

clearMenuAndInputHandler = () ->
	Brew.Display.clearHighlights()
	Brew.Display.clearDialogDisplay()
	Brew.Display.drawDisplayAll()
	Brew.Menu.popup = {}
	input_handler = null


# ------------------------------------------------------------
# mouse clicking functions - game interface
# ------------------------------------------------------------

playerMouseClick = (map_xy) ->
	if input_handler == "inventory"
		playerMouseClick_Inventory(map_xy)

	else
		playerMouseClick_Game(map_xy)

playerMouseAltClick = (map_xy) ->
	if input_handler == "inventory"
		playerMouseAltClick_Inventory(map_xy)

	else
		playerMouseAltClick_Game(map_xy)

playerMouseClick_Game = (map_xy) ->
	# played clicked on the game

	# will get a null map value if we clicked outside of the game panel
	if not map_xy
		Brew.Input.keypress_key(Brew.keymap.INVENTORY[0])

	else
		player = Brew.gamePlayer()
		# dist = Brew.utils.dist2d(player.coordinates, map_xy)	

		# click close to player - action (space bar)
		if player.coordinates.compare(map_xy)
			Brew.Input.keypress_key(Brew.keymap.GENERIC_ACTION[0])

		# see if we clicked an actual edge, in which case it should be obvious
		else if map_xy.x == 0
			Brew.Input.keypress_key(Brew.keymap.MOVE_LEFT[0])
		else if map_xy.x == Brew.panels.game.width - 1
			Brew.Input.keypress_key(Brew.keymap.MOVE_RIGHT[0])
		else if map_xy.y == 0
			Brew.Input.keypress_key(Brew.keymap.MOVE_UP[0])
		else if map_xy.y == Brew.panels.game.height - 1
			Brew.Input.keypress_key(Brew.keymap.MOVE_DOWN[0])

		# click far away from player - move
		else
			offset_xy = map_xy.subtract(player.coordinates)

			# figure out if we are more in the X direction or Y direction
			if Math.abs(offset_xy.x) > Math.abs(offset_xy.y)
				if offset_xy.x > 0
					Brew.Input.keypress_key(Brew.keymap.MOVE_RIGHT[0])
				else 
					Brew.Input.keypress_key(Brew.keymap.MOVE_LEFT[0])

			else if Math.abs(offset_xy.x) < Math.abs(offset_xy.y)
				if offset_xy.y > 0
					Brew.Input.keypress_key(Brew.keymap.MOVE_DOWN[0])
				else 
					Brew.Input.keypress_key(Brew.keymap.MOVE_UP[0])

			else
				console.log("click direction not unique enough")

playerMouseAltClick_Game = (map_xy) ->
	# longclick close to player - action (space bar)

	# figure out which panel we clicked on
	panel = Brew.Display.getPanelAt(map_xy)

	player = Brew.gamePlayer()

	# dist = Brew.utils.dist2d(player.coordinates, map_xy)

	if player.coordinates.compare(map_xy)
		Brew.Input.keypress_key(Brew.keymap.DROP[0])

	# longclick away from player - inventory?
	else
		Brew.Input.keypress_key(Brew.keymap.INVENTORY[0])

playerMouseClick_Inventory = (map_xy) ->
	# figure out which side of the screen

	# will get a null map value if we clicked outside of the game panel
	if not map_xy
		Brew.Input.keypress_key(Brew.keymap.INVENTORY[0])

	else
		screen_xy = Brew.Display.mapToScreen(map_xy)
		dialog_xy = Brew.Display.gameToDialog(screen_xy)

		quarter_length = Brew.config.dialog_display.width / 4

		if dialog_xy.x < quarter_length
			# q1 - left side
			Brew.Input.keypress_key(Brew.keymap.MOVE_LEFT[0])

		else if dialog_xy.x < (quarter_length * 3)
			# q2 - q3 - middle
			Brew.Input.keypress_key(Brew.keymap.GENERIC_ACTION[0])
		else
			# q4 - right side
			Brew.Input.keypress_key(Brew.keymap.MOVE_RIGHT[0])


playerMouseAltClick_Inventory = (map_xy) ->
	# long press on inventory means cancel
	Brew.Input.keypress_key(Brew.keymap.INVENTORY[0])

