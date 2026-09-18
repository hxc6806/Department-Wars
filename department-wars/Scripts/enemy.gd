extends Control

const BAR_GAP = 10.0   # pixels between sprite top and bar bottom

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var health: Health = $Health
@onready var dmg_label: Label = $dmg_label

func _ready() -> void:
	var sprite_size = sprite.get_rect().size * sprite.scale
	custom_minimum_size = sprite_size      # HBox now reserves this much room
	sprite.position = sprite_size / 2.0    # centre the sprite inside the box
	position_health_bar()
	health.health_changed.connect(on_dmg_taken)
	health.died.connect(on_death)
	
func on_dmg_taken(amount):
	dmg_label.text = str(amount)
	await get_tree().create_timer(0.5).timeout
	dmg_label.text = ""
	
func on_death():
	var tween = create_tween()
	tween.tween_property(sprite, "self_modulate:a", 0.0, 1.0)
	await get_tree().create_timer(1.0).timeout
	queue_free()

func position_health_bar() -> void:
	var sprite_size = sprite.get_rect().size * sprite.scale   # texture size x scale
	var sprite_top = sprite.position.y - sprite_size.y / 2.0
	health_bar.position = Vector2(
		sprite.position.x - health_bar.size.x / 2.0,
		sprite_top - health_bar.size.y - BAR_GAP
	)
