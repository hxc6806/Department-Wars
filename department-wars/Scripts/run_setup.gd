extends Node
## Owns map progress for this run; player and deck survive scene transitions.
const Ironworks = preload("res://Map/ironworks_district.gd")
const Skyline = preload("res://Map/skyline_district.gd")
const Route = preload("res://Map/route_state.gd")
var route = Route.new()
var map_view
var map_layer: CanvasLayer
var map_button: Button
var battle: Node
var reward: Node
var encounter_enemy_count := 2
var rewards_remaining := 0
var state := "map"
var district := 0
var backdrop: CanvasLayer
var route_dialog: CanvasLayer

func _enter_tree() -> void:
 deck.player_deck = {"Fireball": 1, "Slash": 3}

func _ready() -> void:
 map_layer=CanvasLayer.new()
 map_layer.layer=20
 add_child(map_layer)
 _build_map()
 var hud=CanvasLayer.new()
 hud.layer=21
 add_child(hud)
 map_button=Button.new()
 map_button.text="MAP"
 map_button.position=Vector2(1630,24)
 map_button.size=Vector2(250,60)
 map_button.add_theme_font_size_override("font_size",26)
 map_button.add_theme_stylebox_override("normal",map_view.style(Color("142234"),Color("ffd478"),8))
 map_button.add_theme_stylebox_override("hover",map_view.style(Color("293c50"),Color("ffd478"),8))
 map_button.add_theme_color_override("font_color",Color("ffd478"))
 hud.add_child(map_button)
 map_button.pressed.connect(_toggle_map)
 get_viewport().size_changed.connect(_layout)
 _layout()
 _show_map()
 if OS.has_feature("editor"):
  var tools = preload("res://Map/debug_tools.gd").new()
  add_child(tools)

func _layout():
 var viewport_size=get_viewport().get_visible_rect().size
 map_view.scale=Vector2.ONE*min(viewport_size.x/1152.0,viewport_size.y/648.0)
 map_view.size=Vector2(1152,648)
 map_view.position=(viewport_size-map_view.size*map_view.scale)/2.0
 if map_layer.visible:
  map_button.position=map_view.position+Vector2(890,567)*map_view.scale
  map_button.size=Vector2(220,42)*map_view.scale
  map_button.add_theme_font_size_override("font_size",int(16*map_view.scale.x))
 else:
  map_button.position=Vector2(viewport_size.x-280,24)
  map_button.size=Vector2(250,60)
  map_button.add_theme_font_size_override("font_size",26)

func _show_map():
 map_view.read_only=state!="map"
 map_layer.show()
 $plr/plr_interface.hide()
 map_button.visible=state!="map"
 map_button.text="RETURN TO ENCOUNTER"
 if not route.pending.is_empty(): map_view._select(route.pending)
 else: map_view._select(route.current)
 _layout()

func _toggle_map():
 if state not in ["battle", "reward"]: return
 # Inspection only during an encounter. Finish enemy animations first.
 if is_instance_valid(battle):
  var manager=battle.get_node_or_null("CardManager")
  if manager and (not manager.player_turn or manager.card_being_dragged != null): return
 if map_layer.visible:
  map_layer.hide()
  $plr/plr_interface.show()
  map_button.text="MAP"
  _layout()
  if is_instance_valid(battle): battle.process_mode=Node.PROCESS_MODE_INHERIT
 else:
  if is_instance_valid(battle): battle.process_mode=Node.PROCESS_MODE_DISABLED
  _show_map()

func _enter_encounter(_id: String, kind: String):
 if state!="map": return
 if kind=="rest":
  $plr/Health.heal(25)
  route.finish()
  _finish_route_or_show_map()
  return
 map_layer.hide()
 $plr/plr_interface.show()
 map_button.show()
 map_button.text="MAP"
 _layout()
 rewards_remaining=2 if kind=="elite" else 1
 if kind=="treasure":
  _open_reward()
 else:
  state="battle"
  encounter_enemy_count=3 if kind=="elite" else 2
  battle=load("res://Scenes/battle_scene.tscn").instantiate()
  add_child(battle)

func battle_won():
 if state!="battle": return
 state="transition"
 call_deferred("_after_battle")

func _after_battle():
 map_button.disabled=true
 await get_tree().create_timer(1.1).timeout
 map_button.disabled=false
 if is_instance_valid(battle):
  remove_child(battle)
  battle.queue_free()
 battle=null
 _open_reward()

func _open_reward():
 state="reward"
 reward=load("res://Scenes/card_select.tscn").instantiate()
 add_child(reward)

func reward_chosen():
 if state!="reward": return
 state="transition"
 call_deferred("_after_reward")

func _after_reward():
 if is_instance_valid(reward):
  remove_child(reward)
  reward.queue_free()
 reward=null
 rewards_remaining-=1
 if rewards_remaining>0:
  _open_reward()
 else:
  route.finish()
  state="map"
  _finish_route_or_show_map()


func _build_map() -> void:
 if is_instance_valid(map_view):
  map_layer.remove_child(map_view)
  map_view.queue_free()
 map_view = Control.new()
 map_view.set_script(preload("res://Map/game_map.gd"))
 map_view.route = route
 map_view.district_index = district
 if district == 1:
  map_view.DATA = Ironworks.NODES.duplicate(true)
  map_view.district_title = "02 / IRONWORKS DISTRICT"
  map_view.background_path = "res://Map/Art/ironworks.png"
 elif district == 2:
  map_view.DATA = Skyline.NODES.duplicate(true)
  map_view.district_title = "03 / SKYLINE DISTRICT"
  map_view.background_path = "res://Map/Art/skyline.png"
 map_layer.add_child(map_view)
 map_view.encounter_requested.connect(_enter_encounter)

func _finish_route_or_show_map() -> void:
 _show_map()
 if route.current != "h": return
 state = "district_clear" if district < 2 else "complete"
 map_view.read_only = true
 map_view.refresh()
 map_button.hide()
 if district == 0:
  _open_route_dialog("CITY ROUTE COMPLETE", "The Ironworks route is open.\nCarry your current health and deck into the next district.", "ENTER IRONWORKS", start_ironworks)
 elif district == 1:
  _open_route_dialog("IRONWORKS ROUTE COMPLETE", "The Skyline route is open.\nCarry your current health and deck into the next district.", "ENTER SKYLINE", start_skyline)
 else:
  _open_route_dialog("SKYLINE ROUTE COMPLETE", "You reached the Observatory.\nAll three available routes are complete.", "NEW RUN", func(): get_tree().reload_current_scene())

func start_ironworks() -> void:
 # Only switch districts between encounters. Existing health/deck are retained.
 if district != 0 or state not in ["map", "district_clear"]: return
 if is_instance_valid(route_dialog):
  route_dialog.queue_free()
  route_dialog = null
 district = 1
 route = Route.new()
 route.configure(Ironworks.GRAPH)
 state = "map"
 _build_map()
 _set_district_background("res://Map/Art/ironworks.png")
 _show_map()

func start_skyline() -> void:
 # Debug may skip ahead from City; normal progression enters from Ironworks.
 if district not in [0, 1] or state not in ["map", "district_clear"]: return
 if is_instance_valid(route_dialog):
  route_dialog.queue_free()
  route_dialog = null
 district = 2
 route = Route.new()
 route.configure(Skyline.GRAPH)
 state = "map"
 _build_map()
 _set_district_background("res://Map/Art/skyline.png")
 _show_map()

func _set_district_background(path: String) -> void:
 if is_instance_valid(backdrop):
  remove_child(backdrop)
  backdrop.queue_free()
 backdrop = CanvasLayer.new()
 backdrop.layer = -5
 add_child(backdrop)
 var background := TextureRect.new()
 background.texture = load(path)
 background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
 background.mouse_filter = Control.MOUSE_FILTER_IGNORE
 backdrop.add_child(background)
 var shade := ColorRect.new()
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 shade.color = Color(0.025, 0.04, 0.07, 0.33)
 shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
 backdrop.add_child(shade)

func _open_route_dialog(title: String, message: String, action_text: String, action: Callable) -> void:
 route_dialog = CanvasLayer.new()
 route_dialog.layer = 30
 add_child(route_dialog)
 var shade := ColorRect.new()
 shade.color = Color(0.015, 0.025, 0.045, 0.92)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 route_dialog.add_child(shade)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 route_dialog.add_child(center)
 var panel := PanelContainer.new()
 panel.custom_minimum_size = Vector2(740, 380)
 var box_style = map_view.style(Color("142234"), Color("ffd478"), 14)
 box_style.set_content_margin_all(32)
 panel.add_theme_stylebox_override("panel", box_style)
 center.add_child(panel)
 var box := VBoxContainer.new()
 box.add_theme_constant_override("separation", 24)
 panel.add_child(box)
 var heading := Label.new()
 heading.text = title
 heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 heading.add_theme_font_size_override("font_size", 32)
 heading.add_theme_color_override("font_color", Color("ffd478"))
 box.add_child(heading)
 var body := Label.new()
 body.text = message
 body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 body.add_theme_font_size_override("font_size", 23)
 box.add_child(body)
 for item in [[action_text, action], ["RETURN TO MENU", func(): get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")]]:
  var button := Button.new()
  button.text = item[0]
  button.custom_minimum_size.y = 56
  button.add_theme_font_size_override("font_size", 23)
  button.add_theme_stylebox_override("normal", map_view.style(Color("20364a"), Color("ffd478"), 8))
  button.add_theme_stylebox_override("hover", map_view.style(Color("344c63"), Color("ffe4a3"), 8))
  button.pressed.connect(item[1])
  box.add_child(button)
