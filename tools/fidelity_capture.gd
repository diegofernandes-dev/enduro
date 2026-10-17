extends SceneTree
## Deterministic daytime fidelity capture at 160×192.
## Usage:
##   godot --path . --headless --script res://tools/fidelity_capture.gd
## Prefer windowed (no --headless) so the viewport texture is valid:
##   godot --path . --script res://tools/fidelity_capture.gd
## Writes build/evidence/fidelity/godot_day_160.png


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(160, 192))
	var err := change_scene_to_file("res://scenes/main.tscn")
	if err != OK:
		push_error("scene load failed %s" % err)
		quit(1)
		return
	for _i in range(12):
		await process_frame

	var main := _find_main()
	if main == null:
		push_error("Main not found")
		quit(1)
		return

	## Fixed poses matching docs/reference/enduro_day_ref_160.png measurements.
	main.session.start_race()
	main.get_node("TitlePause").hide_overlay()
	main.get_node("HUD").set_visible_hud(false)

	var road_view: Node2D = main.get_node("World/RoadView")
	road_view.fidelity_override = {
		"pos_z": 0.0,
		"player_x": 0.0,
		"player_px": 87,
		"curve": 1.0,
		"measured_road": true,
		"km": 970,
		"day": 6,
		"cars_left": 208,
		"cars": [
			## Measured opponent bboxes / colors from reference.
			{"x": 50, "y": 135, "scale": 4, "color": Color8(146, 144, 40)},
			{"x": 100, "y": 102, "scale": 2, "color": Color8(47, 99, 143)},
			{"x": 104, "y": 92, "scale": 2, "color": Color8(151, 108, 50)},
			{"x": 105, "y": 83, "scale": 1, "color": Color8(26, 76, 114)},
		],
	}
	road_view.queue_redraw()
	for _i in range(10):
		await process_frame

	var img: Image = root.get_viewport().get_texture().get_image()
	if img == null:
		push_error("viewport image null")
		quit(1)
		return
	## Viewport stretch may yield the window size; force logical 160×192 nearest.
	if img.get_width() != 160 or img.get_height() != 192:
		img.resize(160, 192, Image.INTERPOLATE_NEAREST)
	var save_err := OK
	for rel in ["res://build/evidence/fidelity", "res://docs/evidence/fidelity"]:
		var out_dir := ProjectSettings.globalize_path(rel)
		DirAccess.make_dir_recursive_absolute(out_dir)
		var abs_path := out_dir.path_join("godot_day_160.png")
		save_err = img.save_png(abs_path)
		print("Saved ", abs_path, " err=", save_err, " size=", img.get_width(), "x", img.get_height())
	quit(0 if save_err == OK else 1)


func _find_main() -> Node:
	var m := root.get_node_or_null("Main")
	if m:
		return m
	for c in root.get_children():
		if c.get_script() != null and String(c.get_script().resource_path).ends_with("main.gd"):
			return c
		var nested := c.find_child("*", true, false)
		if c.name == "Main":
			return c
	## Last child is usually the current scene root.
	if root.get_child_count() > 0:
		var last := root.get_child(root.get_child_count() - 1)
		if last.get_script() != null and String(last.get_script().resource_path).ends_with("main.gd"):
			return last
		if last.has_method("_on_start"):
			return last
	return null
