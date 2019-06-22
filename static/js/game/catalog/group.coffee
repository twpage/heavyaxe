# groups are like families of items (or monsters?)
Brew.group = 
	weapon: 
		id: "weapon"
		code: Brew.unicode.arrow_n
		color: Brew.colors.yellow
		canApply: false
		canEquip: true
		equip_slot: Brew.equip_slot.melee
		equip_verb: "weilding"

	armor: 
		id: "armor"
		code: '['
		canApply: false
		canEquip: true
		equip_slot: Brew.equip_slot.body
		equip_verb: "wearing"

	hat: 
		id: "hat"
		code: '['
		canApply: false
		canEquip: true
		equip_slot: Brew.equip_slot.head
		equip_verb: "wearing"

	scroll:
		id: "scroll"
		code: Brew.unicode.music_note
		color: Brew.colors.yellow
		canEquip: false
		canApply: true

	rune:
		id: "rune"
		code: Brew.unicode.diamond
		color: Brew.colors.white
		canEquip: false
		canApply: true

	info: 
		id: "info"
		code: '?'
		canApply: false

