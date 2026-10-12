extends Node
## Owns map progress for this run; player and deck survive scene transitions.
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

func _enter_tree() -> void:
 deck.player_deck = {"Fireball": 1, "Slash": 3}

func _ready() -> void:
 map_layer=CanvasLayer.new()
 map_layer.layer=20
 add_child(map_layer)
 map_view=Control.new()
 map_view.set_script(preload("res://Map/game_map.gd"))
 map_view.route=route
 map_layer.add_child(map_view)
 map_view.encounter_requested.connect(_enter_encounter)
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
 if state=="map" or state=="transition": return
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
  _show_map()
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
  _show_map()
