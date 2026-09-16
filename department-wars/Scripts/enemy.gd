extends Control

const BAR_GAP = 10.0   # pixels between sprite top and bar bottom

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: TextureProgressBar = $HealthBar

func _ready() -> void:
	var sprite_size = sprite.get_rect().size * sprite.scale
	custom_minimum_size = sprite_size      # HBox now reserves this much room
	sprite.position = sprite_size / 2.0    # centre the sprite inside the box
	position_health_bar()
	print(name, " size=", sprite_size, " sprite=", sprite.position, " bar=", health_bar.position, " barsize=", health_bar.size, " centered=", sprite.centered)

func position_health_bar() -> void:
	var sprite_size = sprite.get_rect().size * sprite.scale   # texture size x scale
	var sprite_top = sprite.position.y - sprite_size.y / 2.0
	health_bar.position = Vector2(
		sprite.position.x - health_bar.size.x / 2.0,
		sprite_top - health_bar.size.y - BAR_GAP
	)
