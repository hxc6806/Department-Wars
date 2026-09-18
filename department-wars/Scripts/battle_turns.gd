extends Node

const ENEMY_DAMAGE := 4
var manager
var player_health: Health
var end_button: Button
var status_label: Label
var turn_number := 1

func _ready() -> void:
	manager = get_parent()
	player_health = manager.get_parent().get_parent().get_node_or_null("plr/Health")
	if player_health:
		player_health.died.connect(_on_player_died)
	_create_controls()
	manager.energy_changed.connect(_refresh_status)
	for enemy in manager.enemy_container.get_children():
		enemy.get_node("Health").died.connect(_on_enemy_died)
	_refresh_status(manager.current_energy)

func _create_controls() -> void:
	var layer = manager.get_node("EnergyHUD")
	end_button = Button.new()
	end_button.name = "EndTurnButton"
	end_button.position = Vector2(28, 108)
	end_button.custom_minimum_size = Vector2(260, 60)
	end_button.text = "END TURN"
	end_button.add_theme_font_size_override("font_size", 26)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("28435c") if state == "hover" else Color("172637")
		style.border_color = Color("f1c66d")
		style.set_border_width_all(2)
		style.set_corner_radius_all(10)
		end_button.add_theme_stylebox_override(state, style)
	layer.add_child(end_button)
	end_button.pressed.connect(end_turn)
	status_label = Label.new()
	status_label.position = Vector2(28, 182)
	status_label.add_theme_font_size_override("font_size", 23)
	status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(status_label)

func _refresh_status(_energy: int = 0) -> void:
	if manager.run_ended:
		return
	var alive := 0
	for enemy in manager.enemy_container.get_children():
		if not enemy.get_node("Health").isdead():
			alive += 1
	end_button.disabled = not manager.player_turn or alive == 0 or player_health == null
	if player_health == null:
		status_label.text = "Run Game.tscn to enable turns."
	else:
		status_label.text = "TURN %d  |  HP %d / %d\nEnemies will deal %d damage.\nEnd turn: discard hand, refill energy and deck." % [turn_number, player_health.current_health, player_health.max_health, alive * ENEMY_DAMAGE]

func _on_enemy_died() -> void:
	_refresh_status()

func end_turn() -> void:
	if not manager.player_turn or manager.run_ended or player_health == null or manager.enemy_container.enemy_count <= 0:
		return
	manager.player_turn = false
	end_button.disabled = true
	manager.card_being_dragged = null
	manager.is_hovering_on_card = false
	for card in manager.player_hand_ref.player_hand:
		card.queue_free()
	manager.player_hand_ref.player_hand.clear()
	manager.energy_changed.emit(manager.current_energy)
	status_label.text = "ENEMY TURN"
	for enemy in manager.enemy_container.get_children():
		if enemy.get_node("Health").isdead():
			continue
		player_health.dmg(ENEMY_DAMAGE)
		if manager.run_ended:
			return
		await get_tree().create_timer(0.25).timeout
	turn_number += 1
	manager.current_energy = manager.max_energy
	manager.get_node("../Deck").reset_for_turn()
	manager.player_turn = true
	manager._update_energy_display()

func _on_player_died() -> void:
	if manager.run_ended:
		return
	manager.run_ended = true
	manager.player_turn = false
	manager.card_being_dragged = null
	end_button.disabled = true
	status_label.text = "RUN OVER"
	call_deferred("_show_death_screen")

func _show_death_screen() -> void:
	get_tree().change_scene_to_file("res://Scenes/death_screen.tscn")
