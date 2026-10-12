extends SceneTree
const Route = preload("res://Map/route_state.gd")
var failures := 0
func check(condition: bool, description: String):
 if condition: print("PASS: " + description)
 else:
  print("FAIL: " + description)
  failures += 1
func _initialize():
 var r = Route.new()
 check(r.available() == ["a", "b"], "New run offers two connected routes")
 check(not r.enter("boss") and r.current == "start", "Cannot skip to a locked encounter")
 check(r.enter("a") and r.pending == "a" and r.available().is_empty(), "Entering encounter locks further travel")
 check(r.finish() and r.current == "a" and r.completed.has("a") and r.available() == ["c", "d"], "Completion unlocks only connected successors")
 check(not r.finish() and not r.enter("a"), "Cannot complete twice or replay an encounter")
 print("Failures: ", failures)
 quit(1 if failures else 0)
