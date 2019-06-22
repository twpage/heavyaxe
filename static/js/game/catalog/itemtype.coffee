Brew.ItemType = 
	randomNames:
		"scroll": [
			"scrsqwrn",
			"zelgomer", 
			"fembloto", 
			"poragorp", 
			"duamxnat",
			"zelgob"
		]

	type_of:
		scroll:
			recall:
				id: "recall"
				real_name: "Scroll of Recall"
				description: "Returns the Axe to your hand, smiting anything in the way"

			sacrifice:
				id: "sacrifice"
				real_name: "Scroll of Sacrifice"
				description: "Restores all stamina, but at a cost of time - The Warden is coming quickly"

			teleport:
				id: "teleport"
				real_name: "Scroll of Teleport"
				description: "Teleports you to another location"

			shield:
				id: "shield"
				real_name: "Scroll of Shield"
				description: "Temporarily shields you from all damage"

			shatter:
				id: "shatter"
				real_name: "Scroll of Shattering"
				description: "Destroys any and all adjacent walls"

		rune:
			portal:
				id: "portal"
				description: "Transports you to another portal rune nearby"

			health:
				id: "health"
				description: "Restores health - but only once"

			recall:
				id: "recall"
				description: "Summons the Axe back to you, smiting any enemies in the way"

			lightning:
				id: "Lightning"
				description: "Throws a powerful bolt of lightning in any direction that is towards an enemy, striking any others along its path"


Brew.ItemType.list_of =
	"scroll": (def.id for own key, def of Brew.ItemType.type_of.scroll)
	"rune": (def.id for own key, def of Brew.ItemType.type_of.rune)

for own key, def of Brew.ItemType.type_of.scroll
	Brew.ItemType.type_of.scroll[key]["unidentified_name"] = "TBD"

