extends SceneTree
var errors := 0
func check(ok: bool, message: String):
 print(("PASS: " if ok else "FAIL: ")+message)
 if not ok: errors+=1
func _initialize(): call_deferred("run")

# Builds a fresh Health + HealthBar pair. Health must be in the tree first so its
# _ready() sets current_health, and bar.health must be set before the bar's _ready().
func make_bar(max_hp:=100) -> TextureProgressBar:
 var hp:=Health.new()
 hp.max_health=max_hp
 root.add_child(hp)
 var bar=load("res://Scenes/health_bar.tscn").instantiate()
 bar.health=hp
 root.add_child(bar)
 return bar

func run():
 var bar=make_bar()
 var hp:Health=bar.health
 check(bar.max_value==100 and bar.value==100,"Bar starts full at max health")

 hp.dmg(30)
 check(bar.value==70,"Bar drops when damaged")

 hp.heal(10)
 check(bar.value==80,"Bar rises when healed")

 hp.heal(999)
 check(bar.value==100 and hp.current_health==100,"Healing cannot overfill the bar")

 hp.dmg(999)
 check(bar.value==0 and hp.current_health==0,"Overkill damage stops at zero")

 hp.heal(50)
 check(bar.value==0,"Dead units cannot be healed back up")

 var small=make_bar(40)
 check(small.max_value==40 and small.value==40,"Bar uses the Health node's max_health")
 small.health.dmg(10)
 check(small.value==30,"Smaller bar tracks damage correctly")

 print("Failures: ",errors)
 quit(1 if errors else 0)
