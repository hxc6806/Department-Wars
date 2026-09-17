class_name deck
extends Node2D

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.4

static var player_deck = {
	"Fireball": 1,
	"Slash": 3
}
static var deck_size = 5
var in_deck = deck_size

func _ready() -> void:
	$RichTextLabel.text = str(in_deck)

func draw_card():
	if in_deck == 0:
		return
	
	in_deck -= 1
	$RichTextLabel.text = str(in_deck)
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	
	# retrieve a random card
	var keys = []
	for key in player_deck:
		for i in range(0, player_deck[key]):
			keys.append(key)
	
	var data = card_data.get_data(keys.pick_random())
	
	new_card.card_id = data.name
	new_card.get_node("CardSprite").texture = data.texture
	#
	
	new_card.position = self.position
	$"../CardManager".add_child.call_deferred(new_card)
	new_card.name = "card"
	$"../CardManager/PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
