extends Node

func _ready() -> void:
	for button in self.get_children():
		var data = card_data.get_data(card_data.get_keys().pick_random())
		
		button.card_id = data.name
		button.texture_normal = data.texture
		button.pressed.connect(func(): 
			print(deck.player_deck)
			queue_free()
			# placeholder for now
			make_battle_scene()
			)

func make_battle_scene():
	var battle_scene = load("res://Scenes/battle_scene.tscn").instantiate()
	get_tree().current_scene.add_child(battle_scene)
