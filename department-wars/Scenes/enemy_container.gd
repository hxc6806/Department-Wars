extends HBoxContainer

func _ready() -> void:
	for i in range(0, 3):
		var enemy_scene = preload("res://Scenes/enemy.tscn")
		var new_enemy = enemy_scene.instantiate()
		var data = enemy_data.get_data(enemy_data.get_keys().pick_random())
		
		new_enemy.name = data.name
		new_enemy.get_node("Sprite2D").texture = data.texture
		new_enemy.get_node("Health").max_health = data.max_health
		add_child(new_enemy)
