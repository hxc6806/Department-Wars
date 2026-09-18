extends Control

@onready var title: Label = $Title
@onready var subtitle: Label = $Subtitle
@onready var return_button: Button = $ReturnButton


func _ready() -> void:
	return_button.pressed.connect(_on_return_pressed)

	# Hide the text and button while keeping the background visible.
	title.modulate.a = 0.0
	subtitle.modulate.a = 0.0
	return_button.modulate.a = 0.0
	return_button.disabled = true

	# Bring each element into view in sequence.
	var tween := create_tween()
	tween.tween_property(title, "modulate:a", 1.0, 0.4)
	tween.tween_property(subtitle, "modulate:a", 1.0, 0.25)
	tween.tween_property(return_button, "modulate:a", 1.0, 0.25)
	tween.tween_callback(_enable_button)


func _enable_button() -> void:
	return_button.disabled = false
	return_button.grab_focus()


func _on_return_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
