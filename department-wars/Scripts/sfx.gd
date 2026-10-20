class_name sfx

# One-shot sound effects on the SFX bus. volume is linear (1.0 = 100%).
# The player is parented to the root (not the caller) so the sound isn't cut off
# when the enemy that made it dies or the scene changes, then frees itself when done.
static func play(path: String, volume := 1.0) -> void:
	if not ResourceLoader.exists(path):
		push_warning("Missing sound: %s" % path)
		return
	var player = AudioStreamPlayer.new()
	player.stream = load(path)
	player.bus = &"SFX"
	player.volume_db = linear_to_db(volume)
	player.finished.connect(player.queue_free)
	Engine.get_main_loop().root.add_child(player)
	player.play()
