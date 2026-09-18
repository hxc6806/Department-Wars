extends HBoxContainer

# keep track of enemies on field. Used for knowing when battle won
var enemy_count = 0

func _ready() -> void:
	for i in range(0, 3):
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
		# if won, change to card select scene
		var new_card_select = load("res://Scenes/card_select.tscn").instantiate()
		get_parent().queue_free()
		get_tree().current_scene.add_child(new_card_select)
