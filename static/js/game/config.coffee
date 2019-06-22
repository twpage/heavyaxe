# W = 13
# H = 17

window.Brew.panels =
	full:
		x: 0
		y: 0
		width: 13
		height: 19

	# messages:
	# 	x: 0
	# 	y: 0
	# 	width: 64
	# 	height: 3

	game:
		x: 0
		y: 0
		width: 13
		height: 17

	# footer:
	# 	x: 0
	# 	y: 33
	# 	width: 64
	# 	height: 1

	playerinfo:
		x: 0
		y: 17
		width: 13
		height: 2


	# viewinfo:
	# 	x: 80
	# 	y: 0
	# 	width: 16
	# 	height: 34

window.Brew.config = 
	level_tiles_width: Brew.panels.game.width
	level_tiles_height: Brew.panels.game.height

	monsters_per_level: 6
	items_per_level: 6
	include_monsters_depth_lag: 3
	include_items_depth_lag: 2
	break_the_walls_down: 0.20
	num_torches: 3
	max_recall_damage: 6
	default_sight_radius: 9
	chance_of_health_rune: 0.5 # make this higher to decrease difficulty
	max_taunt_radius: 6
	initial_doom_level: 140
	starting_scrolls: 2
	scrolls_per_level: 3
	runes_per_level: 3
	sacrifice_cost: 20
	lightning_ammo_per_rune: 2

	animation_speed: 25
	floating_text_timeout: 750

	max_depth: 7
	max_inventory_items: 16

window.Brew.colors = 
	white: [255, 255, 255]
	black: [20, 20, 20]
	normal: [192, 192, 192]
	half_white: [128, 128, 128]
	dim_screen: [50, 50, 50]

	# memory_bg: [30, 30, 30] 
	# memory: [45, 45, 100] 
	memory_bg: [20, 30, 30] 
	memory: [94, 110, 110]
	pair_shade: [0, 51, 102]

	grey: [144,144,144]
	mid_grey: [104, 104, 104]
	dark_grey: [60, 60, 60]
	darker_grey: [40, 40, 40]

	red: [255, 0, 0]
	green: [0, 255, 0]
	blue: [0, 0, 255]
	orange: [255,165,0]
	hf_orange: [255, 126, 0]
	brown: [153, 102, 0]
	purple: [51, 0, 153]
	light_blue: [51, 153, 255]
	yellow: [200, 200, 0]
	steel_blue: [153, 204, 255]
	blood: [165, 0, 0]
	dark_green: [37, 65, 23]
	pink: [255, 62, 150]
	cyan: [0, 205, 205]
	eggplant: [97, 64, 81]
	torch: [150, 75, 30]
	water: [51, 153, 255]
	green_crystal: [0, 153, 10]

	violet: [247,142,246]

	monster_fov: [153, 204, 255]

	inventorymenu:
		title: ROT.Color.fromString("#476BD6")
		border: ROT.Color.fromString("#476BD6")
		text: ROT.Color.fromString("#6D87D6")
		option: ROT.Color.fromString("#6D87D6")
		hotkey: ROT.Color.fromString("white")
	itemmenu:
		title: ROT.Color.fromString("#476BD6")
		border: ROT.Color.fromString("#476BD6")
		text: ROT.Color.fromString("#6D87D6")
		option: ROT.Color.fromString("#6D87D6")
		hotkey: ROT.Color.fromString("white")

# system colors that I change a lot
Brew.colors.doom = Brew.colors.blood
Brew.colors.stamina = Brew.colors.light_blue
Brew.colors.health = Brew.colors.red
Brew.colors.player_shield = Brew.colors.green
Brew.colors.shatter = Brew.colors.green_crystal
Brew.colors.lightning = Brew.colors.yellow
Brew.colors.teleport = Brew.colors.steel_blue
Brew.colors.recall = Brew.colors.hf_orange

window.Brew.unicode = 
	heart: "\u2665"
	# delta: "\u0394"
	horizontal_line: "\u2500"
	corner_topleft: "\u250C"
	corner_topright: "\u2510"
	corner_bottomleft: "\u2514"
	corner_bottomright: "\u2518"
	# target_underscore: "\u02fd"
	block_full: "\u2588" 
	block_fade3: "\u2593"
	block_fade2: "\u2593"
	block_fade1: "\u2591"
	block_quarter: "\u2582"
	block_half: "\u2584"
	block_threequarter: "\u2586"
	arrow_n: "\u2191"
	arrow_s: "\u2193"
	arrow_e: "\u2192"
	arrow_w: "\u2190"
	arrow_se: "\u2198"
	arrow_ne: "\u2197"
	arrow_sw: "\u2199"
	arrow_nw: "\u2196"
	# currency_sign: "\u00A4"
	# filled_circle: "\u25cf"
	middle_dot: "\u00b7"
	# not_sign: "\u00ac"
	# rev_not_sign: "\u2310"
	# degree: "\u00b0"
	omega: "\u03a9"
	# blank_square: "\u25a1"
	# full_square: "\u25a0"
	brogue_statue: "\u00df"
	music_note: "\u266a"
	diamond: "\u25c7"
	ammo: "\u25c8"

window.Brew.flags = 
	conjure_lightning:
		id: "conjure_lightning"
		desc_player: "Throwing Lightning"
		desc_enemy: "Casts bolts of lightning"

	keeps_distance: 
		id: "keeps_distance"
		desc_player: null
		desc_enemy:  "Attacks from a distance"

	see_all: 
		id: "see_all"
		desc_player: "All-seeing"
		desc_enemy: "Is all-seeing"
	
	is_invisible: 
		id: "is_invisible"
		desc_player: "Invisible" 
		desc_enemy: "Is invisible"
	
	flees_when_wounded: 
		id: "flees_when_wounded"
		desc_player: null
		desc_enemy: "Flees when wounded"

	is_stunned: 
		id: "is_stunned"
		desc_player: "Stunned"
		desc_enemy: "Is stunned and can't move"
	
	is_scared: 
		id: "is_scared"
		desc_player: null
		desc_enemy: "Is afraid of you"

	is_flying: 
		id: "is_flying"
		desc_player: "Flying"
		desc_enemy: "Flies"

	is_immobile:
		id: "is_immobile"
		desc_player: null
		desc_enemy: "Does not move"

	is_passive:
		id: "is_passive"
		desc_player: null
		desc_enemy: "Moves only when aggravated"

	is_shielded:
		id: "is_shielded"
		desc_player: "Protected"
		desc_enemy: "Protected by a shield"

	explodes_on_death:
		id: "explodes_on_death"
		desc_player: null
		desc_enemy: "Explodes on death"
		
	is_slow:
		id: "is_slow"
		desc_player: null
		desc_enemy: "Does not move"

	on_fire:
		id: "on_fire"
		desc_player: "On fire"
		desc_enemy: "Is on fire"

	poisoned:
		id: "poisoned"
		desc_player: "Poisoned"
		desc_enemy: "Is poisoned"

	cant_telefrag:
		id: "cant_telefrag"
		desc_player: null
		desc_enemy: "Cannot be killed via Portal"

	respawns_on_death:
		id: "respawns_on_death"
		desc_player: null
		desc_enemy: "Reincarnates after death"

	attacks_in_group:
		id: "attacks_in_group"
		desc_player: null
		desc_enemy: "Attacks in a group"

	is_angry:
		id: "is_angry"
		desc_player: null
		desc_enemy: "Currently enraged"


window.Brew.monster_status =
	HUNT: "hunt player"
	ESCAPE: "flee from player"
	WANDER: "wandering around"
	GUARD: "awake but standing still"
	SLEEP: "sleeping"

window.Brew.paths = 
	to_player: "pathmap to player",
	# only_player: "pathmap to player without monsters"
	from_player: "safety pathmap from player"
	# surround_player: "pathmap surrounding player"

window.Brew.equip_slot = 
	melee: "melee weapon in hand"
	head: "hat head"
	body: "body armor"

window.Brew.errors =
	ATTACK_NOT_KNOWN: "target not known"
	ATTACK_NOT_VISIBLE: "target not visible"
	ATTACK_OUT_OF_RANGE: "target is out of range"
	ATTACK_BLOCKED_TERRAIN: "target is blocked by terrain"
	ATTACK_BLOCKED_MONSTER: "target is blocked by a monster"
	
window.Brew.stat =
	health: "hitpoints"
	level: "xp level"
	power: "power"
	stamina: "stamina"
	doom: "doom"
	ammo: "ammo"
	
window.Brew.input_type =
	gamepad: "gamepad"
	mouse: "mouse"
	keyboard: "keyboard"
	# keys_wasd: "keys_wasd"
	touch: "touch"

window.Brew.helptext = 
########################################
"""
Move                NUMPAD, Arrow Keys, vi keys
Rest/Pickup         Space, NUMPAD 5
Apply (items/doors) a
Inventory           i
Use Ability         1234...
View Abilities      z


[Co-op Mode]
Talk                t
Send Ability        (mouse/click) on
%c{black_hex}____________________%c{}partner screen

Mouse will turn green when and where you 
 can use your current ability/spell 

Long-Click on a monster for pop-up info
 including powers and statuses
"""


window.Brew.tutorial_texts = [
	"Stamina is used when you activate abilities, but also acts as a buffer when you take damage. Try to find a safe spot to rest after each battle to restore your stamina back to full."
	"Stamina can be restored with rest. Once health is lost, it cannot be regained except through flasks of healing."
	"Some monsters attack from far away. Long-click on a monster to pop up info about it."
	"Closing doors can sometimes give you a safe space to rest. Monsters can open doors once they spot you but are less likely to open one at random."
	"Some flasks have harmlful effects, be careful when using unknown flasks for the first time."
	"Press ? at any time for the help screen"
	"Smart Kobolds will shoot at you from far away. As the Squire, use the CHARGE ability to close to melee range quickly. The Apprentice can use forcebolt or fireball to dispatch them quickly."
	"Pay attention to weapon descriptions in your inventory. Some have special effects like piercing and stunning."
]



