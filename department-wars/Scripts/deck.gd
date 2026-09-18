class_name deck
extends Node2D

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.4

static var player_deck = {
	"Fireball": 1,
	"Slash": 3
}
static var deck_size = 5 
var in_deck := 0
var draw_pile: Array = []

func _ready() -> void:
	reset_for_turn()

func reset_for_turn() -> void:
	draw_pile.clear()
	for key in player_deck:
		for i in range(int(player_deck[key])):
			draw_pile.append(key)
	draw_pile.shuffle()
	in_deck = mini(deck_size, draw_pile.size())
	$RichTextLabel.text = str(in_deck)

func draw_card():
	var manager = $"../CardManager"
	if in_deck <= 0 or not manager.player_turn or manager.run_ended or manager.enemy_container.enemy_count <= 0:
		return
	in_deck -= 1
	$RichTextLabel.text = str(in_deck)
	var new_card = preload(CARD_SCENE_PATH).instantiate()
	var data = card_data.get_data(draw_pile.pop_back())
	new_card.card_id = data.name
	new_card.get_node("CardSprite").texture = data.texture
	new_card.position = position
	new_card.name = "card"
	manager.add_child(new_card)
	manager.player_hand_ref.add_card_to_hand(new_card, CARD_DRAW_SPEED)
