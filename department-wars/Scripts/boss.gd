extends "res://Scripts/enemy.gd"

func position_health_bar() -> void:
	health_bar.top_level = true
	health_bar.scale = Vector2(3, 1.3)
	
func _process(_delta: float) -> void:
	var bar_width = health_bar.size.x * health_bar.scale.x
	var boss_centre_x = get_global_rect().get_center().x
	health_bar.position = Vector2(boss_centre_x - bar_width / 2.0, 20)
