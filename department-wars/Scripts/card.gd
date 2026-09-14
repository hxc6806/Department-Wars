extends Node2D

signal hovered(card)
signal hovered_off(card)

var hand_position

func _ready() -> void:
	get_parent().connect_card_signals(self)

func _process(_delta: float) -> void:
	pass

func _on_area_2d_mouse_entered():
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited():
	emit_signal("hovered_off", self)
