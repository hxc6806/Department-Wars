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

	"COMPUTER DEPARTMENT": {
		'Mechamon': {
			"name": 'Mechamon',
			"max_health": 125,
			"texture": preload("res://Assets/EnemySprites/Mechamon.png"),
			"functionality": func(plrObj, _enemyObj):
				plrObj.get_node("Health").dmg(10)
				var rand = randi_range(1, 3)
				if rand == 3:
					status_effect.apply(plrObj, 'Stun', 1),
		},
		'Robokey': {
			"name": 'Robokey',
			"max_health": 35,
			"texture": preload("res://Assets/EnemySprites/Robokey.png"),
			"functionality": func(plrObj, _enemyObj):
				plrObj.get_node("Health").dmg(35),
		},
	},
	"MEDICAL DEPARTMENT": {
		'Betsy': {
			"name": 'Betsy',
			"max_health": 200,
			"texture": preload("res://Assets/EnemySprites/Betsy.png"),
			"functionality": func(plrObj, _enemyObj):
				plrObj.get_node("Health").dmg(20)
				var rand = randi_range(1, 3)
				if rand == 3:
					status_effect.apply(plrObj, 'Stun', 1),
		},
		'Frogter': {
			"name": 'Frogter',
			"max_health": 10,
			"texture": preload("res://Assets/EnemySprites/Frogter.png"),
			"functionality": func(plrObj, _enemyObj):
				plrObj.get_node("Health").heal(35),
		},
	}
}

static var BOSSES = {
	"BUSINESS DEPARTMENT": {
		"name": 'Business Boss',
		"max_health": 200,
		"texture": preload("res://Assets/EnemySprites/Business_Boss.png"),
		"functionality": func(plrObj, _enemyObj): plrObj.get_node("Health").dmg(12)
	},
	"COMPUTER DEPARTMENT": {
		"name": 'Cloaked King',
		"max_health": 175,
		"texture": preload("res://Assets/EnemySprites/Computer_Boss.png"),
		"functionality": func(plrObj, _enemyObj):
			var rand = randi_range(1, 3)
			if rand == 3:
				status_effect.apply(_enemyObj, 'Thorns', 1)
			plrObj.get_node("Health").dmg(12)
			status_effect.apply(plrObj, 'Poison', 3),
	},
	"MEDICAL DEPARTMENT": {
		"name": 'Death Spider',
		"max_health": 255,
		"texture": preload("res://Assets/EnemySprites/Medical_Boss.png"),
		"functionality": func(plrObj, _enemyObj):
			var rand = randi_range(1, 3)
			if rand == 3:
				status_effect.apply(_enemyObj, 'Regen', 1)
				status_effect.apply(_enemyObj, 'Thorns', 1)
			plrObj.get_node("Health").dmg(22)
			status_effect.apply(plrObj, 'Poison', 3),
	},
}

static func get_boss(floor_name):
	return BOSSES.get(floor_name, BOSSES["BUSINESS DEPARTMENT"])

static func get_data(floor_name, key):
	return ENEMIES[floor_name][key]

static func get_keys(floor_name):
	return ENEMIES[floor_name].keys()
