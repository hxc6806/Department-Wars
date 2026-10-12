extends HBoxContainer

# keep track of enemies on field. Used for knowing when battle won
var enemy_count = 0

func _ready() -> void:
	var game = get_tree().current_scene
	var count = game.encounter_enemy_count if game.has_method("battle_won") else 3
	for i in range(0, count):
		var enemy_scene = preload("res://Scenes/enemy.tscn")
		var new_enemy = enemy_scene.instantiate()
		var data = enemy_data.get_data(enemy_data.get_keys().pick_random())
		
		new_enemy.name = data.name
		new_enemy.get_node("Sprite2D").texture = data.texture
		new_enemy.get_node("Health").max_health = data.max_health
		add_child(new_enemy)
		enemy_count += 1
		
		new_enemy.health.died.connect(on_death)

func on_death():
	enemy_count -= 1
	if enemy_count <= 0:
		# Map controller retains run health and owns the reward transition.
		if get_tree().current_scene.has_method("battle_won"):
			get_tree().current_scene.battle_won()
			return
		# Standalone legacy battle fallback
		var new_card_select = load("res://Scenes/card_select.tscn").instantiate()
		get_parent().queue_free()
		get_tree().current_scene.add_child(new_card_select)
