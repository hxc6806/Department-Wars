extends Node2D

signal hovered(card)
signal hovered_off(card)

var hand_position
var card_id
var cost_label: Label
var unavailable_label: Label
var cost_style: StyleBoxFlat
var effect_panel: PanelContainer

func _ready() -> void:
	get_parent().connect_card_signals(self)
	_create_cost_indicator()
	_create_effect_tooltip()
	get_parent().energy_changed.connect(_update_affordability)
	_update_affordability(get_parent().current_energy)

func _create_cost_indicator() -> void:
	var badge := PanelContainer.new()
	badge.name = "EnergyCostBadge"
	badge.position = Vector2(-78, -118)
	badge.custom_minimum_size = Vector2(76, 42)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cost_style = StyleBoxFlat.new()
	cost_style.bg_color = Color("172637")
	cost_style.border_color = Color("f1c66d")
	cost_style.set_border_width_all(2)
	cost_style.set_corner_radius_all(9)
	badge.add_theme_stylebox_override("panel", cost_style)
	add_child(badge)
	cost_label = Label.new()
	cost_label.name = "CostLabel"
	cost_label.text = "%d EP" % int(card_data.get_data(card_id)["energy_cost"])
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 22)
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_child(cost_label)
	unavailable_label = Label.new()
	unavailable_label.name = "InsufficientEnergyLabel"
	unavailable_label.position = Vector2(-81, 76)
	unavailable_label.size = Vector2(162, 40)
	unavailable_label.text = "LOW ENERGY"
	unavailable_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	unavailable_label.add_theme_font_size_override("font_size", 18)
	unavailable_label.add_theme_color_override("font_color", Color("ff8585"))
	unavailable_label.add_theme_color_override("font_outline_color", Color("131721"))
	unavailable_label.add_theme_constant_override("outline_size", 6)
	unavailable_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(unavailable_label)

func _update_affordability(available: int) -> void:
	var affordable := available >= int(card_data.get_data(card_id)["energy_cost"])
	$CardSprite.self_modulate = Color.WHITE if affordable else Color(0.48, 0.48, 0.48, 0.8)
	var accent := Color("f1c66d") if affordable else Color("ff8585")
	cost_style.border_color = accent
	cost_label.add_theme_color_override("font_color", accent)
	unavailable_label.visible = not affordable

func _on_area_2d_mouse_entered():
	if effect_panel: effect_panel.show()
	emit_signal("hovered", self)

func _on_area_2d_mouse_exited():
	if effect_panel: effect_panel.hide()
	emit_signal("hovered_off", self)

func _create_effect_tooltip() -> void:
	var data = card_data.get_data(card_id)
	if not data.has("description"): return
	effect_panel = PanelContainer.new()
	effect_panel.position = Vector2(-210, -300)
	effect_panel.custom_minimum_size = Vector2(420, 140)
	effect_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("101d2cf5")
	style.border_color = Color("ffd478")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(14)
	effect_panel.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = data.description
	label.custom_minimum_size.x = 380
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 24)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effect_panel.add_child(label)
	add_child(effect_panel)
	effect_panel.hide()
