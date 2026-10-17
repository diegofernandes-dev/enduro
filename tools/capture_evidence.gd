extends SceneTree
## Boots main scene, starts race, drives briefly, saves screenshots.
## godot --path . --script res://tools/capture_evidence.gd


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var err := change_scene_to_file("res://scenes/main.tscn")
	if err != OK:
		push_error("Failed to load main scene: %s" % err)
		quit(1)
		return
	await process_frame
	await process_frame

	var main := root.get_child(root.get_child_count() - 1)
	if main == null or not main.has_method("_on_start"):
		# Main may be under current scene
		main = root.get_node_or_null("Main")
	if main == null:
		for c in root.get_children():
			if c.get_script() != null and String(c.get_script().resource_path).ends_with("main.gd"):
				main = c
				break
	if main == null:
		push_error("Main node not found")
		quit(1)
		return

	DirAccess.make_dir_recursive_absolute("res://build/evidence")
	# Title screen
	if main.has_method("_ensure_title"):
		main._ensure_title()
	for _i in range(8):
		await process_frame
	_shot("01_title.png")

	main._on_start()
	await process_frame
	await process_frame
	_shot("02_race_start.png")

	# Simulate driving
	var session: RaceSession = main.session
	for i in range(180):
		session.update(1.0 / 60.0, sin(float(i) * 0.05) * 0.4, true, false)
		await process_frame
	_shot("03_driving.png")

	for i in range(120):
		session.update(1.0 / 60.0, 0.2, true, false)
		await process_frame
	_shot("04_traffic.png")

	main._on_resume() # noop if playing
	session.pause()
	main.get_node("TitlePause").show_pause()
	await process_frame
	await process_frame
	_shot("05_paused.png")

	print("Evidence screenshots written to build/evidence/")
	print("Overtakes at capture: %d  speed: %.1f" % [session.overtake_count, session.vehicle.speed])
	quit(0)


func _shot(name: String) -> void:
	await process_frame
	var img := root.get_viewport().get_texture().get_image()
	var path := "res://build/evidence/%s" % name
	var err := img.save_png(path)
	if err != OK:
		# Fallback absolute
		var abs_path := ProjectSettings.globalize_path(path)
		err = img.save_png(abs_path)
	print("Saved %s err=%s" % [name, err])
