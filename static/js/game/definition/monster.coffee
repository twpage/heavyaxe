window.Brew.monster_def = 
	PLAYER:
		name: ["Sarge", "Simmons", "Grif", "Donut", "Lopez", "Church", "Tucker", "Caboose"].random() # usually overridden!
		group: "player"
		code: '@'
		color: Brew.colors.white # hf_orange
		# light_source: Brew.colors.half_white
		sight_radius: 20
		rank: 0
		attack_range: 1
		damage: 1

	DUMMY:
		name: "Dummy"
		group: "NotAMonster"
		description: "a bug"
		code: 'x'
		color: Brew.colors.white
		sight_radius: 0

	TEMPLAR:
		name: "Templar"
		group: "Monsters"
		description: "A temple guard. Mortal, but still deadly."
		code: 't'
		color: Brew.colors.white
		hp: 2
		damage: 1
		flags: [Brew.flags.keeps_distance.id, Brew.flags.attacks_in_group.id]
		keeps_distance: 2
		attack_range: 1
		rarity: 15
		sight_radius: 5
		min_depth: 0

	GUARDIAN:
		name: "Guardian"
		group: "Monsters"
		description: "Silent guardian with limited vision."
		code: Brew.unicode.brogue_statue
		color: Brew.colors.steel_blue
		hp: 5
		damage: 1
		flags: [Brew.flags.is_passive.id]
		attack_range: 1
		sight_radius: 1
		default_status: Brew.monster_status.GUARD
		rarity: 15
		min_depth: 1


	HIGH_TEMPLAR:
		name: "High Templar"
		group: "Monsters"
		description: "A captain of the temple guard. Mortal, but still deadly."
		code: 't'
		color: Brew.colors.light_blue
		hp: 5
		damage: 1
		flags: []
		attack_range: 1
		rarity: 15
		min_depth: 2

	SENTINEL:
		name: "Sentinel"
		group: "Monsters"
		description: "Slow moving stalker of the temple halls."
		code: Brew.unicode.brogue_statue
		color: Brew.colors.light_blue
		hp: 7
		damage: 1
		flags: [Brew.flags.is_passive.id]
		attack_range: 1
		sight_radius: 1
		default_status: Brew.monster_status.GUARD
		rarity: 15
		min_depth: 3

	PALADIN:
		name: "Paladin"
		group: "Monsters"
		description: "A fierce warrior protected by a divine shield"
		code: 'P'
		color: Brew.colors.normal
		hp: 3
		damage: 1
		flags: [Brew.flags.is_shielded.id, Brew.flags.cant_telefrag.id]
		attack_range: 1
		sight_radius: 4
		rarity: 15
		min_depth: 4

	ZEALOT:
		name: "Zealot"
		group: "Monsters"
		description: "A divine warrior dedicated to making the ultimate sacrifice"
		code: 'Z'
		color: Brew.colors.hf_orange
		hp: 1
		damage: 1
		flags: [Brew.flags.explodes_on_death.id]
		attack_range: 1
		sight_radius: 4
		rarity: 15
		min_depth: 5

	WARDEN:
		name: "The Warden"
		group: "Monsters"
		description: "Dauntless and immortal defender of the temple"
		code: 'W'
		color: Brew.colors.blood
		hp: 6
		damage: 1
		flags: [Brew.flags.respawns_on_death.id]
		attack_range: 1
		rarity: 15


	# the 'keeps distance' flag ties into the "flee from player" pathmap
	# RANGED_MONSTER:
	# 	name: "Shooter"
	# 	group: "MonsterMash"
	# 	description: "Shoots from far away."
	# 	code: 's'
	# 	color: Brew.colors.violet
	# 	hp: 1
	# 	damage: 1
	# 	flags: [Brew.flags.keeps_distance.id]
	# 	attack_range: 5
	# 	rarity: 5
	# 	min_depth: 0

	# # flees when wounded
	# SCARED_MONSTER:
	# 	name: "Runner"
	# 	group: "MonsterMash"
	# 	description: "This monster looks like it doesn't want to be here."
	# 	code: 'r'
	# 	color: Brew.colors.green
	# 	flags: [Brew.flags.flees_when_wounded.id]
	# 	hp: 2
	# 	damage: 1
	# 	rarity: 5
	# 	min_depth: 2

	# # use the immobile flag to stay put
	# STATIONARY_MONSTER:
	# 	name: "Arrow Turret"
	# 	group: "Turret"
	# 	code: Brew.unicode.filled_circle
	# 	color: Brew.colors.light_blue
	# 	flags: [Brew.flags.immobile.id]
	# 	attack_range: 7
	# 	hp: 6
	# 	# without a min_depth, this monster will not be automatically generated

	# flees when wounded
	BOSS_MONSTER:
		name: "The God Jogrmir"
		group: "MonsterMash"
		description: "This is the end for you."
		code: '@'
		color: Brew.colors.violet
		flags: [Brew.flags.cant_telefrag.id]
		hp: 13
		damage: 1
		attack_range: 1
		light_source: Brew.colors.violet
		# without a min_depth, this monster will not be automatically generated
