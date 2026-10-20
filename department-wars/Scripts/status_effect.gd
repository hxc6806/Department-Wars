class_name status_effect

# Each status lists only the hooks it needs.
# on_turn_start(enemyObj, stacks) runs before the enemy acts and returns the new stack count (0 removes it).
# skips_turn: the enemy loses its action while the status is on it.
# tint: colour the enemy sprite turns while the status is on it (blended if it has several).
# dmg_taken_multiplier / dmg_reflect_multiplier: copied onto the target's Health while the status is on it.
# sound / volume: played when the status is applied (volume is linear, 1.0 = 100%).
static var STATUSES = {
	'Poison': {
		"name": 'Poison',
		"description": "Takes X damage at the start of its turn, then X goes down by 1",
		"tint": Color(0.55, 1.0, 0.45),
		"sound": "res://Assets/SoundEffects/Poison.mp3",
		"volume": .15,
		"on_turn_start": func(enemyObj, stacks):
			enemyObj.get_node("Health").dmg(stacks)
			return stacks - 1,
	},

	'Burn': {
		"name": 'Burn',
		"description": "Takes 5 damage at the start of its turn for X turns",
		"tint": Color(1.0, 0.6, 0.25),
		"sound": "res://Assets/SoundEffects/Burn.ogg",
		"volume": .15,
		"on_turn_start": func(enemyObj, stacks):
			enemyObj.get_node("Health").dmg(5)
			return stacks - 1,
	},

	'Stun': {
		"name": 'Stun',
		"description": "Skips its next X turns",
		"skips_turn": true,
		"on_turn_start": func(_enemyObj, stacks): return stacks - 1,
	},

	'Regen': {
		"name": 'Regen',
		"description": "Heals 10% of max HP at the start of its turn for X turns",
		"on_turn_start": func(enemyObj, stacks):
			var health = enemyObj.get_node("Health")
			health.heal(int(ceil(health.max_health * 0.1)))
			return stacks - 1,
	},

	'Thorns': {
		"name": 'Thorns',
		"description": "Takes 75% less damage and reflects 100% of damage taken for X turns",
		"dmg_taken_multiplier": 0.25,
		"dmg_reflect_multiplier": 1.0,
		"on_turn_start": func(_enemyObj, stacks): return stacks - 1,
	},
}

# Stacks are stored on the enemy as metadata (like a Roblox Attribute): {"Poison": 3, "Stun": 1}
static func get_statuses(enemy_obj) -> Dictionary:
	if not enemy_obj.has_meta("statuses"):
		enemy_obj.set_meta("statuses", {})
	return enemy_obj.get_meta("statuses")

static func apply(enemy_obj, status_name, amount := 1):
	if not STATUSES.has(status_name):
		push_warning("Unknown status: %s" % status_name)
		return
	var statuses = get_statuses(enemy_obj)
	statuses[status_name] = statuses.get(status_name, 0) + amount
	var data = STATUSES[status_name]
	if data.has("sound"):
		sfx.play(data.sound, data.get("volume", .05))
	update_visuals(enemy_obj)

static func get_stacks(enemy_obj, status_name) -> int:
	return get_statuses(enemy_obj).get(status_name, 0)

# Called by battle_turns before the enemy acts. Returns false if the enemy loses its turn.
static func tick(enemy_obj) -> bool:
	var statuses = get_statuses(enemy_obj)
	var can_act := true
	for status_name in statuses.keys():
		var data = STATUSES[status_name]
		if data.get("skips_turn", false):
			can_act = false
		if data.has("on_turn_start"):
			statuses[status_name] = data.on_turn_start.call(enemy_obj, statuses[status_name])
		if statuses[status_name] <= 0:
			statuses.erase(status_name)
	update_visuals(enemy_obj)
	return can_act

static func clear(target_obj):
	get_statuses(target_obj).clear()
	update_visuals(target_obj)

static func update_visuals(target_obj):
	update_modifiers(target_obj)
	update_tint(target_obj)
	update_label(target_obj)

# Rebuilds the Health multipliers from scratch so they drop back to normal when a status runs out
static func update_modifiers(target_obj):
	var health = target_obj.get_node_or_null("Health")
	if health == null:
		return
	health.dmg_taken_multiplier = 1.0
	health.dmg_reflect_multiplier = 0.0
	for status_name in get_statuses(target_obj):
		var data = STATUSES[status_name]
		health.dmg_taken_multiplier *= data.get("dmg_taken_multiplier", 1.0)
		health.dmg_reflect_multiplier += data.get("dmg_reflect_multiplier", 0.0)

# Player has no sprite to tint, so its statuses are listed as plain text above its health bar
static func update_label(target_obj):
	var health_bar = target_obj.get_node_or_null("plr_interface/HealthBar")
	if health_bar == null:
		return
	var label = health_bar.get_node_or_null("StatusLabel")
	if label == null:
		label = Label.new()
		label.name = "StatusLabel"
		label.position = Vector2(0, -30)
		label.add_theme_color_override("font_color", Color.BLACK)
		health_bar.add_child(label)
	var parts = []
	var statuses = get_statuses(target_obj)
	for status_name in statuses:
		parts.append("%s %d" % [status_name, statuses[status_name]])
	label.text = "  ".join(parts)

# Uses modulate (not self_modulate) so it doesn't fight the death fade on the sprite
static func update_tint(enemy_obj):
	var sprite = enemy_obj.get_node_or_null("Sprite2D")
	if sprite == null:
		return
	var tints = []
	for status_name in get_statuses(enemy_obj):
		if STATUSES[status_name].has("tint"):
			tints.append(STATUSES[status_name].tint)
	var colour = Color.WHITE
	if not tints.is_empty():
		colour = Color(0, 0, 0, 0)
		for tint in tints:
			colour += tint / tints.size()
	sprite.modulate = colour
