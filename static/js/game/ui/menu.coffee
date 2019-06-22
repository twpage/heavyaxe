window.Brew.Menu =
	
	popup: {}

	showInfoScreen: () ->
		title = Brew.Catalog.getItemName(Brew.Menu.popup.item)
		instructions = "Press any key to dismiss"
		activateDialogScreen(title, instructions, Brew.colors.pink)

		# draw description
		Brew.Display.dialogDisplay().drawText(
			Brew.panels.game.x + 1, 
			Brew.panels.game.y + 3, 
			Brew.Menu.popup.item.description, 
			Brew.panels.game.width - 1
			)

	showRecall: () ->
		# get a collection of paths
		if not Brew.Menu.popup.recall?
			Brew.Menu.popup.recall = Brew.Axe.getRecallPaths()

		# erase previous path, if any
		if Brew.Menu.popup.path?
			for xy in Brew.Menu.popup.path
				Brew.Display.clearHighlightAt(xy)
				Brew.Display.drawMapAt(xy)

		# show the current path
		path = Brew.Menu.popup.recall.getCurrentPath()
		
		Brew.Menu.popup.path = path

		# draw current path shaded
		# line_color = [Brew.colors.hf_orange, Brew.colors.light_blue, Brew.colors.yellow, Brew.colors.violet].random()
		line_color = Brew.colors.recall
		for xy in path
			Brew.Display.setHighlightAt(xy, line_color)
			Brew.Display.drawMapAt(xy)

		Brew.Input.setInputHandler("recall")

	showInventory: () ->
		# draw inventory on dialog screen 

		color_title_hex = ROT.Color.toHex(Brew.colors.inventorymenu.title)
		color_text_hex = ROT.Color.toHex(Brew.colors.inventorymenu.text)
		color_hotkey_hex = ROT.Color.toHex(Brew.colors.inventorymenu.hotkey)

		# initialize items queue, if any
		if not Brew.Menu.popup.inventory?
			Brew.Menu.popup.inventory = Brew.Axe.getScrollInventory()

		item = Brew.Menu.popup.inventory.getExampleOfCurrent()
		item_title = Brew.Catalog.getItemName(item)
		item_color = Brew.Catalog.getItemColor(item)
		activateDialogScreen(item.code, "", item_color)

		text_width = Brew.config.dialog_display.width - 2

		# draw the name
		Brew.Display.dialogDisplay().drawText(
			Brew.panels.game.x + 1, 
			Brew.panels.game.y + 1,
			"%c{white}#{Brew.Catalog.getItemName(item)}%c{}", 
			text_width
			)

		# number of this type of scroll
		number = Brew.Menu.popup.inventory.getNumberOfCurrent()
		Brew.Display.dialogDisplay().drawText(
			Brew.panels.game.x + 1, 
			Brew.panels.game.y + 3,
			"You have #{number} of them", 
			text_width
			)

		# draw the description
		Brew.Display.dialogDisplay().drawText(
			Brew.panels.game.x + 1, 
			Brew.panels.game.y + 5,
			Brew.Catalog.getItemDescription(item), 
			text_width
			)

		# set use messages
		last_input_type = Brew.Input.getLastInputType() 
		action_color_hex = ROT.Color.toHex(item_color)

		if last_input_type == Brew.input_type.keyboard
			text_activate = "Press SPACE"
			text_cycle = Brew.unicode.arrow_w + " left or right " + Brew.unicode.arrow_e
			text_cancel = "Press I or E"

		else if last_input_type == Brew.input_type.gamepad
			text_activate = "Button %c{green}A%c{}"
			text_cycle = Brew.unicode.arrow_w + " left or right " + Brew.unicode.arrow_e
			text_cancel = "Button %c{lightblue}X%c{}"

		else if last_input_type == Brew.input_type.mouse
			text_activate = "Click the middle"
			text_cycle = Brew.unicode.arrow_w + " Click the sides " + Brew.unicode.arrow_e
			text_cancel = "Right- or Long- Click"

		instruction_text_list = [
			"%c{white}Activate%c{}",
			"%c{grey}#{text_activate}%c{}",
			"%c{white}Cycle Items%c{}",
			"%c{grey}#{text_cycle}%c{}",
			"%c{white}Cancel (Esc)%c{}",
			"%c{grey}#{text_cancel}%c{}"
		]

		if last_input_type == Brew.input_type.mouse
			instruction_text_list.push("%c{grey}or click below%c{}")

		for instruction_text, i in instruction_text_list
			Brew.Display.dialogDisplay().drawText(
				Brew.panels.game.x + 1, 
				Brew.config.dialog_display.height - (instruction_text_list.length - i + 1),
				instruction_text,
				text_width
				)

		Brew.Input.setInputHandler("inventory")

	showDied: () ->
		# activateDialogScreen("Died", "")
		Brew.Display.drawDisplayAll({ color_override: Brew.colors.dim_screen})
		# Brew.Display.dialogDisplay().drawText(Brew.panels.game.x + 1, Brew.panels.game.y + 1, "Congratulations, you have died!")

		$("#id_div_onscreeninfo").html(
			"""
			<p>Congratulations, you have died!</p>
			<br/>
			<p><span style='color: violet'>Killed on level #{Brew.gameLevel().depth+1} after #{Brew.Game.turn} turns</span></p>
			<br/>
			<p>Hit <strong>ENTER</strong> to start a new game.</p>
			<p>To try the same seed again, use the link at the bottom of the game screen.</p>
			<br/>
			<p>Thank you for playing!</p>
			"""
		)
		
		Brew.Input.setInputHandler("died")

	showVictory: () ->
		# activateDialogScreen("Victory", "Press ENTER to restart, or ESC for the menu")
		Brew.Display.drawDisplayAll({ color_override: Brew.colors.violet})
		# Brew.Display.dialogDisplay().drawText(Brew.panels.game.x + 1, Brew.panels.game.y + 1, "Congratulations, you have died!")

		$("#id_div_onscreeninfo").html(
			"""
			<p>Victory!</p>
			<br/>
			<p>I have to be honest, I did not think it was possible to win the 7DRL version...</p>
			<br/>
			<p><span style='color: violet'>Smote the Gods on level #{Brew.gameLevel().depth+1} after #{Brew.Game.turn} turns</span></p>
			<br/>
			<p>Hit <strong>ENTER</strong> to start a new game.</p>
			<p>Use the link at the bottom of the game screen to try for a lower turn-count or to challenge your friends!</p>
			<br/>
			<p>Thank you for playing!</p>
			"""
		)
		
		Brew.Input.setInputHandler("died")

	showHelp: () ->
		activateDialogScreen("Help")

		Brew.Display.dialogDisplay().drawText(Brew.panels.game.x + 1, Brew.panels.game.y + 1, Brew.helptext, Brew.panels.game.width - 2)
		Brew.Input.setInputHandler("popup_to_dismiss")

	showMonsterInfo: () ->
		activateDialogScreen(Brew.Menu.popup.monster.name)

		desc = if Brew.Menu.popup.monster.description? then Brew.Menu.popup.monster.description else "No description"
		Brew.Display.dialogDisplay().drawText(Brew.panels.game.x + 1, Brew.panels.game.y + 3, desc, Brew.panels.game.width - 2)

		i = 0
		for flag in Brew.Menu.popup.monster.getFlags()
			desc = Brew.flagDesc[flag][0]
			Brew.Display.dialogDisplay().drawText(Brew.panels.game.x + 1, Brew.panels.game.y + 8 + i, desc, Brew.panels.game.width - 2)
			i += 1

		Brew.Input.setInputHandler("popup_to_dismiss")



# ------------------------------------------------------------
# private functions
# ------------------------------------------------------------

activateDialogScreen = (title, instruct_text, highlight_color) ->
	if instruct_text == ""
		instruct_text = "Press any key to dismiss"

	highlight_color ?= Brew.colors.white

	# dim the screen background
	Brew.Display.drawDisplayAll({ color_override: Brew.colors.dim_screen})

	Brew.Display.resetDialogDisplayTransparency()
	Brew.Display.clearDialogDisplay()
	
	drawBorders(Brew.Display.dialogDisplay(), highlight_color)
	
	color_hex = ROT.Color.toHex(highlight_color)
	Brew.Display.dialogDisplay().drawText(
		Brew.panels.game.x + 1, 
		Brew.panels.game.y + 0, 
		"%c{#{color_hex}}[ #{title} ]"
		)

	# Brew.Display.dialogDisplay().drawText(
	# 	Brew.panels.game.x + 1, 
	# 	Brew.panels.game.y + Brew.panels.game.height - 1, 
	# 	"%c{#{color_hex}}[ #{instruct_text} ]"
	# 	)

	# override this when necessary
	Brew.Input.setInputHandler("popup_to_dismiss")

drawBorders = (display, color, rectangle) ->
	rectangle ?= {}

	hex_color = ROT.Color.toHex(color)
	
	h = rectangle.height ? (Brew.config.dialog_display.height - 1)
	w = rectangle.width ? (Brew.config.dialog_display.width - 1)
	x = rectangle.x ? 0
	y = rectangle.y ? 0

	for row_y in [y..y+h]
		display.draw(x, row_y, "|", hex_color)
		display.draw(x+w, row_y, "|", hex_color)
		
	for col_x in [x..x+w]
		display.draw(col_x, y, Brew.unicode.horizontal_line, hex_color)
		display.draw(col_x, y+h, Brew.unicode.horizontal_line, hex_color)
		
	display.draw(x, y, Brew.unicode.corner_topleft, hex_color)
	display.draw(x, y+h, Brew.unicode.corner_bottomleft, hex_color)
	display.draw(x+w, y, Brew.unicode.corner_topright, hex_color)
	display.draw(x+w, y+h, Brew.unicode.corner_bottomright, hex_color)
