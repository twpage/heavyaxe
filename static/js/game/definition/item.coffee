window.Brew.item_def = 

	##############################
	## SCROLLS
	##############################
	SCROLL_RECALL:
		name: "Scroll of Recall"
		description: "Summons the Axe back to you, smashing enemies along its path."
		group: Brew.group.scroll.id
		itemType: Brew.ItemType.type_of.scroll.recall.id
		color: Brew.colors.recall
		min_depth: 0

	SCROLL_SACRIFICE:
		name: "Scroll of Sacrifice"
		description: "Recharges your Stamina, at a cost of one health. Does not use a turn."
		group: Brew.group.scroll.id
		itemType: Brew.ItemType.type_of.scroll.sacrifice.id
		color: Brew.colors.stamina
		min_depth: 0

	SCROLL_TELEPORT:
		name: "Scroll of Teleport"
		description: "Sends you away to another part of the level."
		group: Brew.group.scroll.id
		itemType: Brew.ItemType.type_of.scroll.teleport.id
		color: Brew.colors.teleport
		min_depth: 0

	# SCROLL_INVISIBLE:
	# 	name: "Scroll"
	# 	group: Brew.group.scroll.id
	# 	itemType: Brew.ItemType.type_of.scroll.invisible.id
	# 	color: Brew.colors.normal
	# 	min_depth: 0

	SCROLL_SHIELD:
		name: "Scroll of Shield"
		description: "Protects you from the next attack. Does not use a turn."
		group: Brew.group.scroll.id
		itemType: Brew.ItemType.type_of.scroll.shield.id
		color: Brew.colors.player_shield
		min_depth: 0

	SCROLL_SHATTER:
		name: "Scroll of Shattering"
		description: "Destroys all adjacent walls."
		group: Brew.group.scroll.id
		itemType: Brew.ItemType.type_of.scroll.shatter.id
		color: Brew.colors.shatter
		min_depth: 0

	##############################
	## RUNE
	##############################
	RUNE_PORTAL:
		name: "Rune of Portal"
		group: Brew.group.rune.id
		itemType: Brew.ItemType.type_of.rune.portal.id
		color: Brew.colors.steel_blue
		min_depth: 0

	RUNE_HEALTH:
		name: "Rune of Health"
		group: Brew.group.rune.id
		itemType: Brew.ItemType.type_of.rune.health.id
		color: Brew.colors.red

	RUNE_RECALL:
		name: "Rune of Recall"
		group: Brew.group.rune.id
		itemType: Brew.ItemType.type_of.rune.recall.id
		color: Brew.colors.hf_orange
		min_depth: 0

	RUNE_LIGHTNING:
		name: "Rune of Lightning"
		group: Brew.group.rune.id
		itemType: Brew.ItemType.type_of.rune.lightning.id
		color: Brew.colors.lightning
		min_depth: 0

	##############################
	## WEAPONS
	##############################

	WPN_AXE:
		name: "Axe"
		group: Brew.group.weapon.id
		color: Brew.colors.yellow
		description: "A massive axe, forged to kill gods."
		flags: []
		damage: 1
		
	##############################
	## OTHER
	##############################

	INFO_POINT:
		name: "Info"
		group: Brew.group.info.id
		# code: "?"
		color: Brew.colors.pink
		min_depth: 100

	# CORPSE:
	# 	name: "Corpse of a brave soldier."
	# 	group: Brew.group.CORPSE.id
	# 	# code: "?"
	# 	description: "Gross."
	# 	color: Brew.colors.normal
	# 	min_depth: 100
