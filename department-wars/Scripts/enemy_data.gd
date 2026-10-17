class_name enemy_data

# Keys must match the floor names in Map/floors.gd exactly.
static var ENEMIES = {
	"BUSINESS DEPARTMENT": {
		'Moneymare': {
			"name": 'Moneymare',
			"max_health": 95,
			"texture": preload("res://Assets/EnemySprites/Moneymare.webp"),
			"functionality": func(plrObj, _enemyObj): plrObj.get_node("Health").dmg(4)
		},
		'Cashmere': {
			"name": 'Cashmere',
			"max_health": 35,
			"texture": preload("res://Assets/EnemySprites/Cashmere.png"),
			"functionality": func(plrObj, _enemyObj): plrObj.get_node("Health").dmg(10)
		},
	},

	"COMPUTER DEPARTMENT": {},
	"MEDICAL DEPARTMENT": {}
}

static var BOSS = {
	"name": 'Business Boss',
	"max_health": 200,
	"texture": preload("res://Assets/EnemySprites/Business_Boss.png"),
	"functionality": func(plrObj, _enemyObj): plrObj.get_node("Health").dmg(12)
}

static func get_data(floor_name, key):
	return ENEMIES[floor_name][key]

static func get_keys(floor_name):
	return ENEMIES[floor_name].keys()
