randomized_groups = []#[Brew.group.scroll.id] #Brew.group.flask.id, Brew.group.wand.id, 

window.Brew.Catalog =
	getArticleForItem: (item) ->
		article = null
		item_name = Brew.Catalog.getItemName(item)

		if item.group == Brew.group.armor.id
			article = ""
		else if item_name[0].toLowerCase() in ['a', 'e', 'i', 'o', 'u']
			article = "an "
		else
			article = "a "

		return article

	getItemName: (item) ->
		# flasks are randomized
		if isRandomizedItemType(item)
			if isIdentified(item)
				name = Brew.ItemType.type_of[item.group][item.itemType].real_name
			else
				name = Brew.ItemType.type_of[item.group][item.itemType].unidentified_name

		# otherwise no randomizing
		else
			name = item.name

		return name

	randomizeItemCatalog: (seed) ->
		# randomizes names of flasks and stuff
		
		# scrolls
		Brew.ItemType.randomNames.scroll = Brew.ItemType.randomNames.scroll.randomize()

		i = 0
		for scroll_type in Brew.ItemType.list_of.scroll
			random_name = Brew.ItemType.randomNames.scroll[i]
			Brew.ItemType.type_of.scroll[scroll_type].unidentified_name = "scroll entitled #{random_name}"
			# Brew.ItemType.type_of.scroll[scroll_type].unidentified_name = "#{random_name}"
			Brew.ItemType.type_of.scroll[scroll_type].is_identified = false
			i += 1

		# # flasks
		# Brew.ItemType.randomNames.flask = Brew.ItemType.randomNames.flask.randomize()

		# i = 0
		# for flask_type in Brew.ItemType.list_of.flask
		# 	random_name = Brew.ItemType.randomNames.flask[i]
		# 	Brew.ItemType.type_of.flask[flask_type].unidentified_name = "#{random_name} Flask"
		# 	Brew.ItemType.type_of.flask[flask_type].is_identified = false
		# 	# console.log("#{random_name} is #{flask_type}")
		# 	i += 1

		# # wands
		# Brew.ItemType.randomNames.wand = Brew.ItemType.randomNames.wand.randomize()

		# i = 0
		# for wand_type in Brew.ItemType.list_of.wand
		# 	random_name = Brew.ItemType.randomNames.wand[i]
		# 	Brew.ItemType.type_of.wand[wand_type].unidentified_name = "#{random_name} Wand"
		# 	Brew.ItemType.type_of.wand[wand_type].is_identified = false
		# 	i += 1

	getItemDescription: (item) ->
		if isRandomizedItemType(item)
			if isIdentified(item)
				desc = Brew.ItemType.type_of[item.group][item.itemType].description
			else
				desc = "Its contents are a mystery"

		else
			desc = item.description ? "Seems normal enough"

		return desc

	getItemColor: (item) ->
		if isIdentified(item)
			return item.color
		else
			return Brew.group[item.group].color

	identify: (item) ->
		if isIdentified(item)
			return false

		if isRandomizedItemType(item)
			Brew.ItemType.type_of[item.group][item.itemType].is_identified = true
			return true

		return false

	isIdentified: (item) ->
		isIdentified(item)

# ------------------------------------------------------------
# private functions
# ------------------------------------------------------------

isIdentified = (item) ->
	if isRandomizedItemType(item)
		return Brew.ItemType.type_of[item.group][item.itemType].is_identified

	else
		return true

isRandomizedItemType = (item) ->
	return item.group in randomized_groups

