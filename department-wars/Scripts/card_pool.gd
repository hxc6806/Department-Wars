extends Node

# Set before adding to the tree: shows the starting decks instead of reward cards
var choosing_deck := false

func _ready() -> void:
	var buttons = get_children()
	# Children are stored card2, card3, card1 - sort so decks go left to right
	buttons.sort_custom(func(a, b): return a.name < b.name)
	var deck_names = card_data.get_deck_names()
	for i in buttons.size():
		var button = buttons[i]
		if choosing_deck:
			if i >= deck_names.size():
				button.hide()
				continue
			button.deck_id = deck_names[i]
			button.texture_normal = card_data.DECKS[deck_names[i]].texture
		else:
			var data = card_data.get_data(card_data.get_reward_card())
			button.card_id = data.name
			button.texture_normal = data.texture
		button.pressed.connect(func():
			print(deck.player_deck)
			for choice in get_children():
				if choice is BaseButton: choice.disabled = true
			if choosing_deck and get_tree().current_scene.has_method("deck_chosen"):
				get_tree().current_scene.deck_chosen()
				return
			if get_tree().current_scene.has_method("reward_chosen"):
				get_tree().current_scene.reward_chosen()
				return
			queue_free()
			# placeholder for now
			make_battle_scene()
			)

func make_battle_scene():
	var battle_scene = load("res://Scenes/battle_scene.tscn").instantiate()
	get_tree().current_scene.add_child(battle_scene)
