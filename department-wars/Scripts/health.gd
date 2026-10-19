class_name Health
extends Node

signal health_changed
signal damaged
signal healed
signal died

@export var max_health: int = 100:
	set(value):
		max_health = value
		health_changed.emit(0)
var current_health: int
# Set by status effects (e.g. Thorns). 1.0 = normal damage, 0.25 = takes 25%
var dmg_taken_multiplier := 1.0
# Fraction of the incoming hit (before dmg_taken_multiplier) that's sent back to the attacker
var dmg_reflect_multiplier := 0.0
# Whoever is currently dealing damage (set by card_manager / battle_turns around each card or enemy action)
static var attacker: Node = null

func _ready() -> void:
	current_health = max_health

func change_hp(amount) -> void:
	var amount_delta
	if amount < 0: 
		amount_delta = max(0, current_health+amount)
	else: 
		amount_delta = min(max_health, current_health+amount)
		
	current_health = amount_delta
	health_changed.emit(amount)

# reflectable is false for reflected damage, so two Thorns users can't bounce damage forever
func dmg(amount: int, reflectable := true) -> void:
	if isdead(): return
	# Reflect is based on the incoming hit, before any reduction
	var reflected = int(round(amount * dmg_reflect_multiplier))
	amount = int(round(amount * dmg_taken_multiplier))
	change_hp(-amount)
	damaged.emit()
	if current_health <= 0:
		died.emit()
	if reflectable and reflected > 0 and is_instance_valid(attacker):
		var attacker_health = attacker.get_node_or_null("Health")
		if attacker_health and attacker_health != self:
			attacker_health.dmg(reflected, false)
		
func heal(amount: int) -> void:
	if isdead(): return
	change_hp(amount)
	healed.emit()
	
func isdead() -> bool:
	return current_health <= 0
