class_name enemy_data

# Keys must match the floor names in Map/floors.gd exactly.
static var ENEMIES = {
	"BUSINESS DEPARTMENT": {
		'Moneymare': {
			"name": 'Mushscroom',
			"max_health": 95,
			"texture": preload("res://Assets/EnemySprites/Moneymare.webp"),
			"functionality": func(plrObj, _enemyObj): plrObj.get_node("Health").dmg(4)
		},
	},

	"COMPUTER DEPARTMENT": {},
	"MEDICAL DEPARTMENT": {}
}

static func get_data(floor_name, key):
	return ENEMIES[floor_name][key]

static func get_keys(floor_name):
	return ENEMIES[floor_name].keys()
