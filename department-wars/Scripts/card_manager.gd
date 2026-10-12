extends Node2D

const COLLISION_MASK_CARD = 1
const DEFAULT_CARD_SPEED = 0.1

signal energy_changed(available: int)

@export var max_energy: int = 3
var current_energy: int = 0
var energy_label: Label
var player_turn: bool = true
var run_ended: bool = false

var hud_layer: CanvasLayer
var deck_overlay: Control
var deck_grid: GridContainer

func can_afford(card_id: String) -> bool:
	return player_turn and not run_ended and enemy_container.enemy_count > 0 and current_energy >= int(card_data.get_data(card_id)["energy_cost"])

func _create_energy_display() -> void:
	var layer := CanvasLayer.new()
	layer.name = "EnergyHUD"
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(28, 28)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("151b2bee")
	style.border_color = Color("f1c66d")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	layer.add_child(panel)
	energy_label = Label.new()
	energy_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	energy_label.add_theme_font_size_override("font_size", 28)
	energy_label.add_theme_color_override("font_color", Color("f1c66d"))
	panel.add_child(energy_label)
	_update_energy_display()
	_setup_deck_overlay(layer)

func _setup_deck_overlay(hud_layer: CanvasLayer) -> void:
	deck_overlay = Control.new()
	deck_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	deck_overlay.visible = false
	hud_layer.add_child(deck_overlay)
	
	#Makes background dimmed
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	deck_overlay.add_child(bg)
	
	#Panel for the centre
	var center_panel := PanelContainer.new()
	center_panel.custom_minimum_size = Vector2(800, 500)
	center_panel.anchors_preset = Control.PRESET_CENTER
	center_panel.position = (get_viewport_rect().size - Vector2(800, 500)) / 2.0
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("151b2b")
	panel_style.border_color = Color("f10000ff")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(16)
	panel_style.content_margin_left = 20
	panel_style.content_margin_right = 20
	panel_style.content_margin_top = 20
	panel_style.content_margin_bottom = 20
	center_panel.add_theme_stylebox_override("panel", panel_style)
	deck_overlay.add_child(center_panel)
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	center_panel.add_child(vbox)
	
	#Title
	var title := Label.new()
	title.text = "YOUR DECK"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("f10000ff"))
	vbox.add_child(title)
	
	#Allows scrolling
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)
	deck_grid = GridContainer.new()
	deck_grid.columns = 5
	deck_grid.add_theme_constant_override("h_separation", 20)
	deck_grid.add_theme_constant_override("v_separation", 20)
	scroll.add_child(deck_grid)
	
	#Button to close
	var close_btn := Button.new()
	close_btn.text = "CLOSE"
	close_btn.custom_minimum_size = Vector2(140, 40)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(func(): deck_overlay.hide())
	vbox.add_child(close_btn)
	
	var deck_node = get_node_or_null("../Deck")
	if deck_node and deck_node.has_signal("deck_right_clicked"):
		deck_node.deck_right_clicked.connect(show_deck_overlay)

func show_deck_overlay() -> void:
	if not deck_overlay:
		return
	
	#Remove any previous cards
	for child in deck_grid.get_children():
		child.queue_free()
	
	#Fill the deck with the card textures
	for card_name in deck.player_deck:
		var count: int = deck.player_deck[card_name]
		if count <= 0:
			continue
			
		var data = card_data.get_data(card_name)
		
		for i in range(count):
			var card_box := VBoxContainer.new()
			card_box.alignment = BoxContainer.ALIGNMENT_CENTER
			
			var card_rect := TextureRect.new()
			card_rect.texture = data["texture"]
			card_rect.custom_minimum_size = Vector2(110, 150)
			card_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			card_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			card_box.add_child(card_rect)
			
			var name_label := Label.new()
			name_label.text = card_name
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_label.add_theme_font_size_override("font_size", 16)
			name_label.add_theme_color_override("font_color", Color("f10000ff"))
			card_box.add_child(name_label)
			
			deck_grid.add_child(card_box)
			
	deck_overlay.show()

func _update_energy_display() -> void:
	energy_label.text = "ENERGY  %d / %d" % [current_energy, max_energy]
	energy_changed.emit(current_energy)

var screen_size: Vector2
var card_being_dragged = null
var is_hovering_on_card
var player_hand_ref

@onready var enemy_container = $"../enemy_container"

func _ready() -> void:
	current_energy = maxi(0, max_energy)
	_create_energy_display()
	screen_size = get_viewport_rect().size
	player_hand_ref = $PlayerHand
	$"../InputManager".connect("left_mouse_button_released", on_left_click_released)
	var turns = preload("res://Scripts/battle_turns.gd").new()
	turns.name = "BattleTurns"
	add_child(turns)

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x, 0, screen_size.x), clamp(mouse_pos.y, 0, screen_size.y))

func raycast_check_for_card():
	var space_state = get_viewport().world_2d.direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_viewport().get_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null
	
func get_enemy_under_mouse():
	var mouse_pos = get_global_mouse_position()
	for enemy in enemy_container.get_children():
		if not enemy.get_node("Health").isdead() and enemy.get_global_rect().has_point(mouse_pos):
			return enemy
	return null

func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	if not is_hovering_on_card and not card_being_dragged:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	if not card_being_dragged:
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered and new_card_hovered != card:
			highlight_card(new_card_hovered, true)
			is_hovering_on_card = true
		else:
			is_hovering_on_card = false
	highlight_card(card, false)

func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1.0, 1.0)
		card.z_index = 0

func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
			
	return highest_z_card

func start_drag(card):
	if not player_turn or run_ended or enemy_container.enemy_count <= 0:
		return
	card_being_dragged = card
	card.scale = Vector2(1.0, 1.0)

func finish_drag():
	if card_being_dragged:
		var enemy = get_enemy_under_mouse()
		if enemy and can_afford(str(card_being_dragged.card_id)):
			current_energy -= int(card_data.get_data(card_being_dragged.card_id)["energy_cost"])
			_update_energy_display()
			card_data.get_data(card_being_dragged.card_id)['functionality'].call(enemy)
			
			player_hand_ref.remove_card_from_hand(card_being_dragged)
			card_being_dragged.queue_free()
		else:
			card_being_dragged.scale = Vector2(1.05, 1.05)
			player_hand_ref.add_card_to_hand(card_being_dragged, DEFAULT_CARD_SPEED)
	card_being_dragged = null

func on_left_click_released():
	if card_being_dragged:
		finish_drag()
