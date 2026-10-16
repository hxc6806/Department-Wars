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
 check(r.available() == ["start"], "New run offers only the first assignment")
 check(not r.enter("boss") and not r.enter("a") and r.current == "", "Cannot skip to a locked encounter")
 check(r.enter("start") and r.finish() and r.available() == ["a", "b"], "First assignment unlocks two connected routes")
 check(r.enter("a") and r.pending == "a" and r.available().is_empty(), "Entering encounter locks further travel")
 check(r.finish() and r.current == "a" and r.completed.has("a") and r.available() == ["c", "d"], "Completion unlocks only connected successors")
 check(not r.finish() and not r.enter("a"), "Cannot complete twice or replay an encounter")
 print("Failures: ", failures)
 quit(1 if failures else 0)
