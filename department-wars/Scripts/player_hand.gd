extends Node2D

const HAND_COUNT = 8
const CARD_SCENE_PATH = "res://Scenes/card.tscn"
var CARD_WIDTH = 150
const HAND_Y_POSITION = 800

var player_hand = []
var centre_screen_x

func _ready() -> void:
	centre_screen_x = get_viewport().size.x / 2
	
	var card_scene = preload(CARD_SCENE_PATH)
	for i in range(HAND_COUNT):
		var new_card = card_scene.instantiate()
		get_parent().add_child.call_deferred(new_card)
		new_card.name = "Card"
		add_card_to_hand(new_card)

func add_card_to_hand(card):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_position()
	else:
		animate_card_to_position(card, card.hand_position)
	
func update_hand_position():
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_hand_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position)
		
func calculate_hand_position(index):
	CARD_WIDTH = max(250 - (player_hand.size() * 10), 150)
	var x_offset = (player_hand.size() - 1) * CARD_WIDTH
	var x_pos = centre_screen_x + index * CARD_WIDTH - x_offset / 2
	return x_pos

func animate_card_to_position(card, new_position):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.1)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position()
