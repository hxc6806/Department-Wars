extends CanvasLayer
## Editor-only shortcuts. They call the existing health and victory systems.
var game: Node
var panel: PanelContainer
var travel_button: Button
var heal_button: Button
var win_button: Button

func _ready() -> void:
	if not OS.has_feature("editor"):
		queue_free()
		return
	game = get_parent()
	layer = 40
	panel = PanelContainer.new()
	panel.position = Vector2(28, 300)
	panel.custom_minimum_size = Vector2(390, 220)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("111c2cf5")
	style.border_color = Color("ffd478")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	var title := Label.new()
	title.text = "TEST TOOLS / F9 TO CLOSE"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("ffd478"))
	box.add_child(title)
	travel_button = _button(box, "SKIP TO NEXT FLOOR", skip_to_next_floor)
	heal_button = _button(box, "RESTORE HEALTH", restore_health)
	win_button = _button(box, "WIN CURRENT BATTLE", win_current_battle)
	panel.hide()

func _button(box: VBoxContainer, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 45
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(callback)
	box.add_child(button)
	return button

func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.has_feature("editor"): return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F9:
		panel.visible = not panel.visible
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not is_instance_valid(panel) or not panel.visible: return
	travel_button.disabled = game.is_last_floor() or game.state != "map"
	heal_button.disabled = game.state not in ["map", "battle"] or (game.state == "battle" and not _can_win())
	win_button.disabled = not _can_win()

func skip_to_next_floor() -> void:
	if game.is_last_floor() or game.state != "map": return
	game.start_next_floor()
	panel.hide()

func restore_health() -> void:
	if game.state not in ["map", "battle"]: return
	if game.state == "battle" and not _can_win(): return
	var health = game.get_node("plr/Health")
	health.heal(health.max_health)
	game.map_view.refresh()
	if is_instance_valid(game.battle):
		var manager = game.battle.get_node("CardManager")
		manager.energy_changed.emit(manager.current_energy)

func _can_win() -> bool:
	if game.state != "battle" or not is_instance_valid(game.battle): return false
	var manager = game.battle.get_node("CardManager")
	return manager.player_turn and not manager.run_ended and manager.card_being_dragged == null

func win_current_battle() -> void:
	if not _can_win(): return
	# Damage triggers normal death signals, animations, rewards and map progress.
	# Resume an encounter if its map inspection screen was open.
	if game.map_layer.visible: game._toggle_map()
	for enemy in game.battle.get_node("enemy_container").get_children():
		var health = enemy.get_node("Health")
		if not health.isdead(): health.dmg(health.current_health)
	panel.hide()
