extends Node
## Owns map progress for this run; player and deck survive scene transitions.
const Floors = preload("res://Map/floors.gd")
const Route = preload("res://Map/route_state.gd")
const Map = preload("res://Map/route_map.gd")
var route = Route.new()
var map_view
var map_layer: CanvasLayer
var map_button: Button
var battle: Node
var reward: Node
var encounter_enemy_count := 2
var is_boss_encounter := false
var rewards_remaining := 0
var state := "map"
var floor_index := 0
## One node layout per floor. Rolled on _ready unless set beforehand (tests set fixed layouts).
var layouts: Array = []
var backdrop: CanvasLayer
var backdrop_image: TextureRect
var music: AudioStreamPlayer
var route_dialog: CanvasLayer
## Show the character deck pick before the map (tests turn this off).
var choose_starting_deck := true

func _enter_tree() -> void:
 deck.player_deck = {"Fireball": 1, "Slash": 3}
 card_data.loot_pool = []
 card_data.chosen_deck = ""

func _ready() -> void:
 if layouts.is_empty():
  var rng=RandomNumberGenerator.new()
  rng.randomize()
  for i in Floors.FLOORS.size(): layouts.append(Floors.generate(rng))
 _add_floor_background()
 _play_floor_music()
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
 map_button.add_theme_stylebox_override("normal",map_view.style(Map.BUTTON,Map.BORDER))
 map_button.add_theme_stylebox_override("hover",map_view.style(Map.BUTTON_HOVER,Map.BORDER))
 map_button.add_theme_color_override("font_color",Map.TEXT)
 hud.add_child(map_button)
 map_button.pressed.connect(_toggle_map)
 get_viewport().size_changed.connect(_layout)
 _layout()
 if choose_starting_deck: _open_deck_select()
 else: _show_map()
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
 elif not route.current.is_empty(): map_view._select(route.current)
 else: map_view._select("start")
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
 rewards_remaining=3 if kind=="boss" else 2 if kind=="elite" else 1
 if kind=="treasure":
  _open_reward()
 else:
  state="battle"
  is_boss_encounter=kind=="boss"
  encounter_enemy_count=3 if kind=="elite" else 2
  battle=load("res://Scenes/battle_scene.tscn").instantiate()
  add_child(battle)

func battle_won():
 if state!="battle": return
 state="transition"
 call_deferred("_after_battle")

func _after_battle():
 status_effect.clear($plr)
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

## Same 3-card picker as rewards, but showing the character decks.
func _open_deck_select():
 state="deck_select"
 map_layer.hide()
 map_button.hide()
 $plr/plr_interface.hide()
 reward=load("res://Scenes/card_select.tscn").instantiate()
 reward.choosing_deck=true
 add_child(reward)

func deck_chosen():
 if state!="deck_select": return
 state="transition"
 call_deferred("_after_deck_select")

func _after_deck_select():
 if is_instance_valid(reward):
  remove_child(reward)
  reward.queue_free()
 reward=null
 state="map"
 _show_map()

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
  if is_boss_encounter:
   is_boss_encounter=false
   state="floor_clear"
   if is_last_floor(): get_tree().change_scene_to_file("res://Scenes/win_screen.tscn")
   else: start_next_floor()
   return
  state="map"
  _finish_route_or_show_map()


func _build_map() -> void:
 if is_instance_valid(map_view):
  map_layer.remove_child(map_view)
  map_view.queue_free()
 map_view = Control.new()
 map_view.set_script(preload("res://Map/game_map.gd"))
 map_view.route = route
 var floor_data: Dictionary = Floors.FLOORS[floor_index]
 map_view.DATA = layouts[floor_index].duplicate(true)
 map_view.district_title = "%02d / %s" % [floor_index + 1, floor_data.name]
 map_view.background_path = floor_data.background
 map_layer.add_child(map_view)
 map_view.encounter_requested.connect(_enter_encounter)

func is_last_floor() -> bool:
 return floor_index >= Floors.FLOORS.size() - 1

func _finish_route_or_show_map() -> void:
 _show_map()

func start_next_floor() -> void:
 # Only switch floors between encounters. Existing health/deck are retained.
 if is_last_floor() or state not in ["map", "floor_clear"]: return
 if is_instance_valid(route_dialog):
  route_dialog.queue_free()
  route_dialog = null
 floor_index += 1
 route = Route.new()
 route.configure(Floors.GRAPH)
 state = "map"
 _build_map()
 _add_floor_background()
 _play_floor_music()
 _show_map()

## Loops the current floor's track on the Music bus, so the options volume slider controls it.
func _play_floor_music() -> void:
 if not is_instance_valid(music):
  music = AudioStreamPlayer.new()
  music.bus = &"Music"
  music.finished.connect(music.play)
  add_child(music)
 var floor_data: Dictionary = Floors.FLOORS[floor_index]
 var path: String = floor_data.music
 music.stream = load(path) if ResourceLoader.exists(path) else null
 # Player volume x Music bus volume (the slider), so 0.2 here at a 50% slider plays at 10%.
 music.volume_db = linear_to_db(floor_data.get("volume", 1.0))
 if music.stream: music.play()

## Full-screen floor image shown behind battles and rewards.
func _add_floor_background() -> void:
 if not is_instance_valid(backdrop):
  backdrop = CanvasLayer.new()
  backdrop.layer = -5
  add_child(backdrop)
  backdrop_image = TextureRect.new()
  backdrop_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
  backdrop_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
  backdrop_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
  backdrop_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
  backdrop.add_child(backdrop_image)
 backdrop_image.texture = Floors.texture(Floors.FLOORS[floor_index].background)

func _open_route_dialog(title: String, message: String, action_text: String, action: Callable) -> void:
 route_dialog = CanvasLayer.new()
 route_dialog.layer = 30
 add_child(route_dialog)
 var shade := ColorRect.new()
 shade.color = Color(0, 0, 0, 0.6)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 route_dialog.add_child(shade)
 var center := CenterContainer.new()
 center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 route_dialog.add_child(center)
 var panel := PanelContainer.new()
 panel.custom_minimum_size = Vector2(740, 380)
 var box_style = map_view.style(Map.PANEL, Map.BORDER)
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
 heading.add_theme_color_override("font_color", Map.ACCENT)
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
  button.add_theme_stylebox_override("normal", map_view.style(Map.BUTTON, Map.BORDER))
  button.add_theme_stylebox_override("hover", map_view.style(Map.BUTTON_HOVER, Map.BORDER))
  button.pressed.connect(item[1])
  box.add_child(button)
