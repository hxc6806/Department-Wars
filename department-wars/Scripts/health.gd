class_name Health
extends Node

signal health_changed
signal damaged
signal healed
signal died

@export var max_health: int = 100
var current_health: int

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

func dmg(amount: int) -> void:
	if isdead(): return
	change_hp(-amount)
	damaged.emit()
	if current_health <= 0:
		died.emit()
		
func heal(amount: int) -> void:
	if isdead(): return
	change_hp(amount)
	healed.emit()
	
func isdead() -> bool:
	return current_health <= 0
