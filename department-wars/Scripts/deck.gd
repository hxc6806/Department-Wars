extends Node2D

const CARD_SCENE_PATH = "res://Scenes/card.tscn"
const CARD_DRAW_SPEED = 0.4

var player_deck = ["card", "card", "card"]

func _ready() -> void:
	$RichTextLabel.text = str(player_deck.size())

func draw_card():
	if player_deck.size() == 0:
		return
	
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$DeckSprite.visible = false
		$RichTextLabel.visible = false
	$RichTextLabel.text = str(player_deck.size())
	
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	new_card.position = self.position
	$"../CardManager".add_child.call_deferred(new_card)
	new_card.name = "card"
	$"../CardManager/PlayerHand".add_card_to_hand(new_card, CARD_DRAW_SPEED)
