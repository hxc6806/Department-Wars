extends Control

func _ready() -> void:
	$VBoxContainer/Button.pressed.connect(_start_game)
	$VBoxContainer/Button3.pressed.connect(func(): get_tree().quit())

func _start_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
