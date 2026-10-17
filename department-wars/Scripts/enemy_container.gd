extends HBoxContainer

const Floors = preload("res://Map/floors.gd")

const FORCE_BOSS = false

# keep track of enemies on field. Used for knowing when battle won
var enemy_count = 0
var is_boss_fight = false

func _ready() -> void:
	var game = get_tree().current_scene
	var in_run = game.has_method("battle_won")
	var floor_name = Floors.FLOORS[game.floor_index].name if in_run else Floors.FLOORS[0].name
	is_boss_fight = FORCE_BOSS or (in_run and game.is_boss_encounter)
	if is_boss_fight:
		spawn_boss(floor_name)
		return

	var count = game.encounter_enemy_count if in_run else 3
	for i in range(0, count):
		var enemy_scene = preload("res://Scenes/enemy.tscn")
		var new_enemy = enemy_scene.instantiate()
		var pool = floor_name if not enemy_data.get_keys(floor_name).is_empty() else "BUSINESS DEPARTMENT"
		var data = enemy_data.get_data(pool, enemy_data.get_keys(pool).pick_random())
		
		new_enemy.name = data.name
		new_enemy.get_node("Sprite2D").texture = data.texture
		new_enemy.get_node("Health").max_health = data.max_health
		new_enemy.functionality = data.get("functionality")
		add_child(new_enemy)
		enemy_count += 1
		
		new_enemy.health.died.connect(on_death)

func spawn_boss(floor_name) -> void:
	var boss = preload("res://Scenes/boss.tscn").instantiate()
	var data = enemy_data.get_boss(floor_name)
	boss.name = data.name
	boss.get_node("Sprite2D").texture = data.texture
	boss.get_node("Health").max_health = data.max_health
	boss.functionality = data.functionality
	add_child(boss)
	enemy_count = 1
	boss.health.died.connect(on_death)

func on_death():
	enemy_count -= 1
	if enemy_count <= 0:
		# Map controller retains run health and owns the reward transition.
		if get_tree().current_scene.has_method("battle_won"):
			get_tree().current_scene.battle_won()
			return
		if is_boss_fight:
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://Scenes/win_screen.tscn")
			return
		# Standalone legacy battle fallback
		var new_card_select = load("res://Scenes/card_select.tscn").instantiate()
		get_parent().queue_free()
		get_tree().current_scene.add_child(new_card_select)
