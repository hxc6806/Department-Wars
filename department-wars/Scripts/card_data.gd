class_name card_data

static var CARDS = {
	'Fireball': {
		"name": 'Fireball',
		"texture": preload("res://Assets/CardSprites/Fireball.png"),
		"functionality": func(target): target.get_node("Health").dmg(15)
	},
	
	'Slash': {
		"name": 'Slash',
		"texture": preload("res://Assets/CardSprites/Slash.png"),
		"functionality": func(target): target.get_node("Health").dmg(5)
	}
}

static func get_data(key):
	return CARDS[key]

static func get_keys():
	return CARDS.keys()
