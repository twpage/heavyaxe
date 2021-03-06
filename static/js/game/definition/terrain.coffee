window.Brew.terrain_def = 
	EMPTY:
		name: 'Empty'
		code: ' '
		color: Brew.colors.normal

	WALL:
		name: 'Wall'
		code: '#'
		
		color: Brew.colors.dark_grey
		color_randomize: [5, 0, 0]

		bgcolor: [150, 150, 150]
		bgcolor_randomize: [0, 5, 5]
		
		blocks_walking: true
		blocks_vision: true
		blocks_flying: true

		description: "rough-hewn rock wall"
		
	WALL_TORCH:
		name: 'Wall Torch'
		code: '^'
		
		bgcolor: [150, 150, 150]
		bgcolor_randomize: [0, 5, 5]
		color: Brew.colors.torch
		light_source: Brew.colors.white

		blocks_walking: true
		blocks_vision: true
		blocks_flying: true

		description: "a flickering torch"

	FLOOR:
		name: 'Cavern Floor'
		code: ['.', "`", Brew.unicode.middle_dot]
		color: Brew.colors.normal
		color_randomize: [20, 20, 0]

		bgcolor: Brew.colors.dark_grey
		bgcolor_randomize: [0, 8, 8]
		
		show_gore: true

		description: "smoothed cavern floor"
		walkover: "You step onto the weathered cavern floor"

	# CHASM:
	# 	name: 'Chasm'
	# 	code: ':'
	# 	# color: Brew.colors.normal
	# 	color: [220, 220, 220]
	# 	bgcolor: Brew.colors.eggplant
	# 	# bgcolor_randomize: [0, 5, 5]
	# 	blocks_walking: true

	# 	description: "a deep chasm dropping off to the darkness below"
	# 	walkover: "You float above the dark chasm below"

	STAIRS_DOWN:
		name: "Stairs Down"
		code: Brew.unicode.omega
		color: Brew.colors.white
		bgcolor: Brew.colors.dark_grey
		bgcolor_randomize: [0, 8, 8]

		description: "a rough-hewn set of stairs leading deeper"
		walkover: "You step around some stairs leading down into darkness"
		
	STAIRS_UP:
		name: "Stairs Up"
		code: '<'
		color: Brew.colors.white
		bgcolor: Brew.colors.dark_grey
		bgcolor_randomize: [0, 8, 8]

		desc: "a rough-hewn set of stairs leading back to the surface"
		walkover: "You step around some stairs leading upwards"
		
	DOOR_CLOSED:
		name: "Closed Door"
		code: '+'
		color: Brew.colors.yellow
		bgcolor: Brew.colors.brown

		blocks_vision: true
		blocks_walking: true
		can_open: true
		blocks_flying: true
		can_apply: true

		description: "a sturdy wooden door, shut tight"

	DOOR_OPEN:
		name: "Open Door"
		code: '-'
		color: Brew.colors.yellow
		bgcolor: Brew.colors.brown

		can_apply: true

		description: "a sturdy wooden door, wide open"
		walkover: "You pass through the doorway"
		

	ALTAR:
		name: "Altar"
		code: '_'
		color: Brew.colors.white
	# 	can_apply: true
