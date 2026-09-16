extends Node2D

var CARD_WIDTH = 150
const HAND_Y_POSITION = 800
const DEFAULT_CARD_SPEED = 0.1

var player_hand = []
var centre_screen_x

func _ready() -> void:
	centre_screen_x = get_viewport_rect().size.x / 2

func add_card_to_hand(card, speed):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_position(speed)
	else:
		animate_card_to_position(card, card.hand_position, DEFAULT_CARD_SPEED)
	
func update_hand_position(speed):
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_hand_position(i), HAND_Y_POSITION)
		var card = player_hand[i]
		card.hand_position = new_position
		animate_card_to_position(card, new_position, speed)
		
func calculate_hand_position(index):
	CARD_WIDTH = max(250 - (player_hand.size() * 10), 150)
	var x_offset = (player_hand.size() - 1) * CARD_WIDTH
	var x_pos = centre_screen_x + index * CARD_WIDTH - x_offset / 2
	return x_pos

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_position(DEFAULT_CARD_SPEED)
