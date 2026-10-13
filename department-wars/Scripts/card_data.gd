class_name card_data

static var CARDS = {
	'Fireball': {
		"name": 'Fireball',
		"energy_cost": 2,
		"texture": preload("res://Assets/CardSprites/Fireball.png"),
		"functionality": func(target): target.get_node("Health").dmg(24)
	},
	
	'Slash': {
		"name": 'Slash',
		"energy_cost": 1,
		"texture": preload("res://Assets/CardSprites/Slash.png"),
		"functionality": func(target): target.get_node("Health").dmg(12)
	},
	
	'Curse': {
		"name": 'Curse',
		"energy_cost": 1,
		"texture": preload("res://Assets/CardSprites/Curse.png"),
		"functionality": func(target): target.get_node("Health").dmg(16)
	}
}

static func get_data(key):
	return CARDS[key]

static func get_keys():
	return CARDS.keys()
