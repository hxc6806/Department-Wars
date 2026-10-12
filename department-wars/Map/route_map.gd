extends Control
## Standalone design preview. No battle, deck, menu or health scripts are modified.
signal encounter_requested(id: String, encounter_type: String)
const Route = preload("res://Map/route_state.gd")
const GOLD = Color("ffd478")
const INK = Color("111c2c")
const MUTED = Color("8596ad")
const DATA = {
 "start": [Vector2(490,520), "RECEPTION", "start", "Your journey begins here."],
 "a": [Vector2(330,455), "OFFICE FLOOR", "battle", "Standard battle\nProposed reward: choose one card."],
 "b": [Vector2(660,455), "SECURITY DIVISION", "elite", "Harder battle\nProposed reward: stronger card choices."],
 "c": [Vector2(220,350), "SUPPLY ROOM", "treasure", "Treasure stop\nProposed reward: choose a useful bonus."],
 "d": [Vector2(490,350), "CROSSROADS", "battle", "Standard battle\nProposed reward: choose one card."],
 "e": [Vector2(760,350), "STAFF LOUNGE", "rest", "Rest stop\nProposed effect: recover some health."],
 "f": [Vector2(335,245), "PATROL", "battle", "Standard battle\nProposed reward: choose one card."],
 "g": [Vector2(650,245), "ENFORCERS", "elite", "Harder battle\nProposed reward: stronger card choices."],
 "h": [Vector2(490,150), "EXECUTIVE HALL", "battle", "Last encounter before the department boss."],
 "boss": [Vector2(490,52), "DIRECTOR’S OFFICE", "boss", "Boss encounter coming soon."]
}
var route = Route.new()
var selected := ""
var buttons := {}
var panel: Panel
var heading: Label
var detail: Label
var action: Button
var status: Label
var small_font: Font
var pixel_font: Font
var map_origin := Vector2(30,58)

func _ready():
 pixel_font = load("res://Map/Art/pixel_font.ttf")
 small_font = ThemeDB.fallback_font
 var bg = TextureRect.new()
 bg.texture = load("res://Map/Art/city.jpg")
 bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(bg)
 var shade = ColorRect.new()
 shade.color = Color(0.025,0.05,0.09,0.91)
 shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(shade)
 # Lines are drawn in a child so the background stays behind them.
 var lines = Node2D.new()
 lines.name = "Connections"
 add_child(lines)
 lines.draw.connect(_draw_connections.bind(lines))
 label_at("DEPARTMENT WARS", Vector2(30,18), 17, GOLD, true)
 label_at("01 / CITY DISTRICT", Vector2(770,19), 16, Color.WHITE)
 label_at("ROUTE DESIGN PREVIEW", Vector2(945,22), 11, MUTED)
 for id in DATA:
  var button = Button.new()
  button.position = DATA[id][0] + map_origin - Vector2(26,26)
  button.size = Vector2(52,52)
  button.text = symbol(DATA[id][2])
  button.add_theme_font_size_override("font_size",25)
  button.tooltip_text = DATA[id][1]
  button.pressed.connect(_select.bind(id))
  button.mouse_entered.connect(func(): button.scale = Vector2(1.07,1.07))
  button.mouse_exited.connect(func(): button.scale = Vector2.ONE)
  button.pivot_offset = Vector2(26,26)
  add_child(button)
  buttons[id] = button
  var caption = label_at(DATA[id][1],button.position + Vector2(-60,57),11,MUTED)
  caption.size.x = 172
  caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 panel = Panel.new()
 panel.position = Vector2(870,100)
 panel.size = Vector2(260,440)
 panel.add_theme_stylebox_override("panel",style(Color("142234"),Color("344256"),12))
 add_child(panel)
 heading = label_at("CHOOSE YOUR\nROUTE",Vector2(890,126),16,GOLD,true)
 detail = label_at("Select a glowing node.\n\nPreview the route ahead\nbefore committing.\n\nGold = available\nTeal = completed\nRing = current position",Vector2(890,202),17,Color("d6dfeb"))
 detail.size = Vector2(220,190)
 detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 action = Button.new()
 action.position = Vector2(890,420)
 action.size = Vector2(220,52)
 action.text = "SELECT A NODE"
 action.add_theme_stylebox_override("normal",style(GOLD,GOLD,6))
 action.add_theme_stylebox_override("hover",style(Color("ffe5ad"),GOLD,6))
 action.add_theme_color_override("font_color",INK)
 action.add_theme_color_override("font_hover_color",INK)
 action.add_theme_font_size_override("font_size",16)
 action.pressed.connect(_activate)
 add_child(action)
 status = label_at("",Vector2(890,483),13,MUTED)
 status.size.x=220
 status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 var reset = Button.new()
 reset.text = "RESTART PREVIEW"
 reset.position=Vector2(890,567)
 reset.size=Vector2(220,36)
 reset.pressed.connect(func():
  route=Route.new()
  selected=""
  heading.text="CHOOSE YOUR\nROUTE"
  detail.text="Select a glowing node to\nexplore another route."
  refresh())
 add_child(reset)
 label_at("BATTLE    /    ELITE    /    TREASURE    /    REST    /    BOSS",Vector2(30,629),11,MUTED)
 refresh()

func style(fill: Color, border: Color, radius: int) -> StyleBoxFlat:
 var s=StyleBoxFlat.new()
 s.bg_color=fill
 s.border_color=border
 s.set_border_width_all(2)
 s.set_corner_radius_all(radius)
 return s

func label_at(text: String, pos: Vector2, font_size: int, color: Color, pixel := false) -> Label:
 var l=Label.new()
 l.text=text
 l.position=pos
 l.add_theme_color_override("font_color",color)
 l.add_theme_font_size_override("font_size",font_size)
 l.add_theme_font_override("font",pixel_font if pixel else small_font)
 l.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(l)
 return l

func symbol(kind: String) -> String:
 return {"start":"•", "battle":"⚔", "elite":"!", "treasure":"▣", "rest":"+", "boss":"♛"}[kind]

func refresh():
 for id in buttons:
  var available=route.available().has(id)
  var done=route.completed.has(id)
  var here=id == (route.pending if not route.pending.is_empty() else route.current)
  var color=Color("72839a")
  if available: color=GOLD
  if done: color=Color("58c9b4")
  if here: color=Color("f4f2e7")
  var b: Button=buttons[id]
  b.add_theme_stylebox_override("normal",style(INK,color,26))
  b.add_theme_stylebox_override("hover",style(Color("293c50"),color,26))
  b.add_theme_stylebox_override("focus",style(Color(0,0,0,0),Color.WHITE,26))
  b.add_theme_color_override("font_color",color)
  b.add_theme_color_override("font_hover_color",Color.WHITE)
  b.modulate.a=1.0 if available or done or here or id==selected else 0.85
 action.disabled=not route.available().has(selected) and route.pending.is_empty()
 action.text="COMPLETE PREVIEW STOP" if not route.pending.is_empty() else "TRAVEL HERE"
 status.text="Preview only: combat, rewards\nand healing are not connected."
 if route.current=="boss" and route.pending.is_empty(): status.text="Route preview complete.\nRestart to try another path."
 get_node("Connections").queue_redraw()

func _select(id: String):
 selected=id
 heading.text=DATA[id][1].replace(" ","\n")
 detail.text=DATA[id][3]
 if not route.available().has(id):
  detail.text += "\n\n" + ("Current location." if route.current==id else "Follow the connected route\nto reach this stop.")
 refresh()

func _activate():
 if not route.pending.is_empty():
  route.finish()
  heading.text="ROUTE\nUPDATED"
  detail.text="Preview stop completed.\n\nChoose your next connected\nnode to continue."
 elif route.enter(selected):
  encounter_requested.emit(selected,DATA[selected][2])
  heading.text="AT THE\nENCOUNTER"
  detail.text="This is a design preview.\n\nThe final game will open the\nencounter here and return\nafter it is completed."
 refresh()

func _draw_connections(canvas: Node2D):
 for source in Route.GRAPH:
  for target in Route.GRAPH[source]:
   var a: Vector2=DATA[source][0]+map_origin
   var b: Vector2=DATA[target][0]+map_origin
   var colour=Color("64748b")
   if source==route.current and route.pending.is_empty(): colour=GOLD
   elif route.completed.has(target) and (route.completed.has(source) or source=="start"): colour=Color("58c9b4")
   var delta=(b-a).normalized()
   canvas.draw_line(a+delta*32,b-delta*32,colour,2.0,true)
 var center: Vector2=DATA[route.pending if not route.pending.is_empty() else route.current][0]+map_origin
 canvas.draw_arc(center,33,0,TAU,64,Color("f4f2e7"),2,true)
