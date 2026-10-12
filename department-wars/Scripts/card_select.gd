extends TextureButton

var card_id
var idle_alpha: float = 1.0

func _ready() -> void:
	self_modulate.a = idle_alpha
	mouse_entered.connect(highlight)
	mouse_exited.connect(unhighlight)
	pressed.connect(on_press)

func on_press():
	if deck.player_deck.has(card_id):
		deck.player_deck[card_id] += 1
	else:
		deck.player_deck[card_id] = 1

func highlight():
	var tween = create_tween()
	tween.tween_property(self, "self_modulate:a", 1.0, .1)

func unhighlight():
	var tween = create_tween()
	tween.tween_property(self, "self_modulate:a", idle_alpha, .1)
