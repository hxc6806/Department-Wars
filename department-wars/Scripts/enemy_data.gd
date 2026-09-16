class_name enemy_data

static var ENEMIES = {
	'Mushscroom': {
		"name": 'Mushscroom',
		"max_health": 95,
		"texture": preload("res://Assets/EnemySprites/Mushscroom.png"),
	},
	
	'Zombiescroom': {
		"name": 'Zombiescroom',
		"max_health": 120,
		"texture": preload("res://Assets/EnemySprites/Zombiescroom.png"),
	}
}

static func get_data(key):
	return ENEMIES[key]

static func get_keys():
	return ENEMIES.keys()
