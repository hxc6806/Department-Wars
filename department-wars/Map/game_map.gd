extends "res://Map/route_map.gd"
var read_only := false
func _ready():
 super._ready()
 detail.text="Select a gold node.\n\nChoose your route towards\nthe Exam.\n\nGold = available\nTeal = completed\nRing = current position"
 for child in get_children():
  if child is Button and child.text == "RESTART PREVIEW": child.hide()
  if child is Label and child.text == "ROUTE DESIGN PREVIEW": child.hide()
 refresh()
func _select(id: String):
 selected=id
 heading.text=DATA[id][1].replace(" ","\n")
 detail.text=DATA[id][3]
 if read_only: detail.text+="\n\nFinish this encounter\nto continue."
 refresh()
func refresh():
 super.refresh()
 action.text="TRAVEL HERE"
 action.disabled=read_only or not route.available().has(selected) or selected=="boss"
 var game=get_parent().get_parent()
 var health=game.get_node_or_null("plr/Health")
 status.text="HP %d / %d" % [health.current_health,health.max_health] if health else ""
 if route.current=="h": status.text+="\nRoute complete."
func _activate():
 if read_only or selected=="boss": return
 if route.enter(selected):
  encounter_requested.emit(selected,DATA[selected][2])
 refresh()
