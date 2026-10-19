extends Node

var errors := 0
func check(ok: bool, message: String):
 print(("PASS: " if ok else "FAIL: ")+message)
 if not ok: errors+=1

func make_bar(max_hp:=100) -> TextureProgressBar:
 var hp:=Health.new()
 hp.max_health=max_hp
 add_child(hp)
 var bar=load("res://Scenes/health_bar.tscn").instantiate()
 bar.health=hp
 add_child(bar)
 return bar

func _ready():
 var bar=make_bar()
 var hp:Health=bar.health

 # 1. Raising max health resizes the bar straight away
 hp.max_health=150
 check(bar.max_value==150,"test_1_bar_max_updates_when_max_health_increases")

 # 2. Current health is unchanged by the upgrade itself
 check(bar.value==100,"test_2_bar_value_unchanged_by_upgrade")

 # 3. Player can now heal above the old cap
 hp.heal(50)
 check(bar.value==150,"test_3_bar_fills_past_old_max_after_heal")

 print("Failures: ",errors)
 # Wait before quitting so the editor's Output panel receives the prints
 await get_tree().create_timer(0.5).timeout
 get_tree().quit(1 if errors else 0)
