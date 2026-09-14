extends TextureProgressBar

@export var health: Health

func _ready() -> void:
	max_value = health.max_health
	value = health.current_health
	health.health_changed.connect(_update_health)

func _update_health() -> void:
	value = health.current_health
	
