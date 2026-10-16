extends Control
## Standalone design preview. No battle, deck, menu or health scripts are modified.
signal encounter_requested(id: String, encounter_type: String)
const Route = preload("res://Map/route_state.gd")
const Floors = preload("res://Map/floors.gd")
## Neutral colours: plain dark greys, white text, square corners.
const ACCENT = Color.WHITE
const TEXT = Color("e6e6e6")
const PANEL = Color("1e1e1e")
const BORDER = Color("5a5a5a")
const BUTTON = Color("2d2d2d")
const BUTTON_HOVER = Color("3d3d3d")
const MUTED = Color("a0a0a0")
## On-screen size of each node image (map is laid out at 1152x648 and scaled to the window).
const NODE_SIZE := 80.0
var DATA = Floors.generate(RandomNumberGenerator.new())
var district_title := "01 / " + Floors.FLOORS[0].name
var background_path: String = Floors.FLOORS[0].background
var route = Route.new()
var selected := ""
var buttons := {}
var panel: Panel
var heading: Label
var detail: Label
var action: Button
var status: Label
var map_origin := Vector2(30,58)

func _ready():
 var bg = TextureRect.new()
 bg.texture = Floors.texture(background_path)
 bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
 bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
 add_child(bg)
 # Lines are drawn in a child so the background stays behind them.
 var lines = Node2D.new()
 lines.name = "Connections"
 add_child(lines)
 lines.draw.connect(_draw_connections.bind(lines))
 #label_at("DEPARTMENT WARS", Vector2(30,18), 17, ACCENT)
 #label_at(district_title, Vector2(770,19), 16, Color.WHITE)
 label_at("ROUTE DESIGN PREVIEW", Vector2(945,22), 11, MUTED)
 for id in DATA:
  # Nodes are just the image: no background, ring or caption.
  var button = Button.new()
  button.position = DATA[id][0] + map_origin - Vector2.ONE*NODE_SIZE/2
  button.size = Vector2.ONE*NODE_SIZE
  for state in ["normal","hover","pressed","focus","disabled"]:
   button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
  # Use the node image if it exists; otherwise fall back to the text symbol.
  button.icon = Floors.texture(Floors.TYPES[DATA[id][2]].image)
  if button.icon:
   button.expand_icon = true
   button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
  else:
   button.text = symbol(DATA[id][2])
  button.add_theme_font_size_override("font_size",36)
  button.pressed.connect(_select.bind(id))
  button.mouse_entered.connect(func(): button.scale = Vector2(1.08,1.08))
  button.mouse_exited.connect(func(): button.scale = Vector2.ONE)
  button.pivot_offset = Vector2.ONE*NODE_SIZE/2
  add_child(button)
  buttons[id] = button
 panel = Panel.new()
 panel.position = Vector2(870,100)
 panel.size = Vector2(260,440)
 panel.add_theme_stylebox_override("panel",style(PANEL,BORDER))
 add_child(panel)
 heading = label_at("CHOOSE YOUR\nROUTE",Vector2(890,126),16,ACCENT)
 detail = label_at("Select a bright node.\n\nPreview the route ahead\nbefore committing.\n\nWhite line = available path\nTeal line = completed path",Vector2(890,202),17,TEXT)
 detail.size = Vector2(220,190)
 detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 action = Button.new()
 action.position = Vector2(890,420)
 action.size = Vector2(220,52)
 action.text = "SELECT A NODE"
 action.add_theme_stylebox_override("normal",style(BUTTON,BORDER))
 action.add_theme_stylebox_override("hover",style(BUTTON_HOVER,BORDER))
 action.add_theme_stylebox_override("disabled",style(PANEL,BORDER))
 action.add_theme_color_override("font_disabled_color",MUTED)
 action.add_theme_color_override("font_color",TEXT)
 action.add_theme_color_override("font_hover_color",ACCENT)
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
 #label_at("ASSIGNMENTS    /    QUIZZES    /    RESTAURANT    /    HOME    /    EXAM",Vector2(30,629),11,MUTED)
 refresh()

func style(fill: Color, border: Color) -> StyleBoxFlat:
 var s=StyleBoxFlat.new()
 s.bg_color=fill
 s.border_color=border
 s.set_border_width_all(2)
 return s

func label_at(text: String, pos: Vector2, font_size: int, color: Color) -> Label:
 var l=Label.new()
 l.text=text
 l.position=pos
 l.add_theme_color_override("font_color",color)
 l.add_theme_font_size_override("font_size",font_size)
 l.mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(l)
 return l

func symbol(kind: String) -> String:
 return Floors.TYPES[kind].symbol

func refresh():
 for id in buttons:
  var available=route.available().has(id)
  var done=route.completed.has(id)
  var here=id == (route.pending if not route.pending.is_empty() else route.current)
  # No ring any more: brightness shows state. Available/current = full, completed = slightly dim, locked = dark.
  var tint=Color(0.4,0.4,0.45)
  if done: tint=Color(0.7,0.7,0.7)
  if available or here: tint=Color.WHITE
  buttons[id].modulate=tint
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
 for source in route.graph:
  for target in route.graph[source]:
   var a: Vector2=DATA[source][0]+map_origin
   var b: Vector2=DATA[target][0]+map_origin
   var colour=Color("6e6e6e")
   if source==route.current and route.pending.is_empty(): colour=ACCENT
   elif route.completed.has(target) and route.completed.has(source): colour=Color("58c9b4")
   var delta=(b-a).normalized()
   var gap=NODE_SIZE/2+4
   canvas.draw_line(a+delta*gap,b-delta*gap,colour,2.0,true)
