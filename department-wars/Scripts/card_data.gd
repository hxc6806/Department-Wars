class_name card_data

static var CARDS = {
	'Fantasy': {
		'Fireball': {
			"name": 'Fireball',
			"energy_cost": 2,
			"texture": preload("res://Assets/CardSprites/Fireball.png"),
			"functionality": func(plrObj, _enemyObj):
				_enemyObj.get_node("Health").dmg(24) 
				status_effect.apply(_enemyObj, 'Burn', 2),
			"description": "Deals 24 damage to the targeted enemy and applies burn"
		},
	
		'Slash': {
			"name": 'Slash',
			"energy_cost": 1,
			"texture": preload("res://Assets/CardSprites/Slash.png"),
			"functionality": func(plrObj, _enemyObj): _enemyObj.get_node("Health").dmg(12),
			"description": "Deals 12 damage to the targeted enemy"
		},
	
		'Curse': {
			"name": 'Curse',
			"energy_cost": 1,
			"texture": preload("res://Assets/CardSprites/Curse.png"),
			"functionality": func(plrObj, _enemyObj): _enemyObj.get_node("Health").dmg(16),
			"description": "Deals 16 damage to the targeted enemy"
		}
	},
	
	'Engineer': {
		'Bomb': {
			"name": 'Bomb',
			"energy_cost": 3,
			"texture": preload("res://Assets/CardSprites/Bomb.png"),
			"functionality": func(plrObj, _enemyObj):
				for enemy in _enemyObj.get_parent().get_children():
					enemy.get_node("Health").dmg(17),
			"description": "Deals 17 damage to all enemies"
		},
		'FlameThrower': {
			"name": 'FlameThrower',
			"energy_cost": 1,
			"texture": preload("res://Assets/CardSprites/FlameThrower.png"),
			"functionality": func(plrObj, _enemyObj):
				for enemy in _enemyObj.get_parent().get_children():
					status_effect.apply(enemy, 'Burn', 3),
			"description": "Apply burn for 3 turns to all enemies"
		},
		'StunGrenade': {
			"name": 'StunGrenade',
			"energy_cost": 1,
			"texture": preload("res://Assets/CardSprites/StunGrenade.png"),
			"functionality": func(plrObj, _enemyObj):
				for enemy in _enemyObj.get_parent().get_children():
					status_effect.apply(enemy, 'Stun', 2),
			"description": "Apply stun for 2 turns to all enemies"
		}
	},
	
	'Medic': {
		'Bandaid': {
			"name": 'Bandaid',
			"energy_cost": 1,
			"texture": preload("res://Assets/CardSprites/Bandaid.png"),
			"functionality": func(plrObj, _enemyObj):
				status_effect.apply(plrObj, 'Regen', 2),
			"description": "Grants regeneration for 2 turns"
		},
		'Thorns': {
			"name": 'Thorns',
			"energy_cost": 2,
			"texture": preload("res://Assets/CardSprites/Thorns.png"),
			"functionality": func(plrObj, _enemyObj):
				status_effect.apply(plrObj, 'Thorns', 2),
			"description": "Grants Thorns for 2 turns"
		},
		'BensKnife': {
			"name": 'BensKnife',
			"energy_cost": 0,
			"texture": preload("res://Assets/CardSprites/BensKnife.png"),
			"functionality": func(plrObj, _enemyObj):
				_enemyObj.get_node("Health").dmg(3)
				status_effect.apply(_enemyObj, 'Poison', 2),
			"description": "Applies 2 stacks of poison"
		},
	}
}

static var DECKS = {
	'Fantasy':{
		"texture": preload("res://Assets/DeckSprites/Fantasy.png")
	},
	'Engineer':{
		"texture": preload("res://Assets/DeckSprites/Engineer.png")
	},
	'Medic':{
		"texture": preload("res://Assets/DeckSprites/Medic.png")
	},
}

const STARTING_CARDS = 2
const STARTING_COPIES = 3

# Every card in the chosen deck; rewards are drawn from here
static var loot_pool: Array = []
static var chosen_deck := ""

# Looks a card up by name across every deck
static func get_data(key):
	for deck_name in CARDS:
		if CARDS[deck_name].has(key):
			return CARDS[deck_name][key]

static func get_deck_names():
	return DECKS.keys()

# Deals the starting cards from the chosen deck; the whole deck becomes the loot pool
static func choose_deck(deck_name):
	chosen_deck = deck_name
	var cards = CARDS[deck_name].keys()
	loot_pool = cards.duplicate()
	cards.shuffle()
	deck.player_deck = {}
	for card_name in cards.slice(0, STARTING_CARDS):
		deck.player_deck[card_name] = STARTING_COPIES

static func get_reward_card():
	if not loot_pool.is_empty():
		return loot_pool.pick_random()
	# No deck chosen yet (e.g. tests skip the deck select): use every card
	var all_cards = []
	for deck_name in CARDS:
		all_cards.append_array(CARDS[deck_name].keys())
	return all_cards.pick_random()
