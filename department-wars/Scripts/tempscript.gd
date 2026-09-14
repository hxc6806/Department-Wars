extends Button

@onready var health: Health = $"../Health"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(func(): health.dmg(20))
	
