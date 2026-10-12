class_name card_data

static var CARDS = {
	'Fireball': {
		"name": 'Fireball',
		"description": "Deal 24 damage to one enemy.",
		"energy_cost": 2,
		"texture": preload("res://Assets/CardSprites/Clean/fireball.svg"),
		"functionality": func(target): target.get_node("Health").dmg(24)
	},
	
	'Slash': {
		"name": 'Slash',
		"description": "Deal 12 damage to one enemy.",
		"energy_cost": 1,
		"texture": preload("res://Assets/CardSprites/Clean/slash.svg"),
		"functionality": func(target): target.get_node("Health").dmg(12)
	},
	
	'Curse': {
		"name": 'Curse',
		"description": "Deal 16 damage to one enemy.",
		"energy_cost": 1,
		"texture": preload("res://Assets/CardSprites/Clean/curse.svg"),
		"functionality": func(target): target.get_node("Health").dmg(16)
	}
}

static func get_data(key):
	return CARDS[key]

static func get_keys():
	return CARDS.keys()
