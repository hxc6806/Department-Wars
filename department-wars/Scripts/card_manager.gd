extends Node2D

const COLLISION_MASK_CARD = 1
const DEFAULT_CARD_SPEED = 0.1

signal energy_changed(available: int)

@export var max_energy: int = 3
var current_energy: int = 0
var energy_label: Label
var player_turn: bool = true
var run_ended: bool = false

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
