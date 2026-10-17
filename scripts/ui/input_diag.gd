extends CanvasLayer
## Development-only controller diagnostic. Not part of the original Enduro experience.

@onready var text: Label = $Margin/Panel/Margin/Text


func _process(_delta: float) -> void:
	if not visible:
		return
	var lines: PackedStringArray = []
	lines.append("INPUT DIAG (dev) — F1 to close")
	lines.append("COMPATIBILIDADE FÍSICA PENDENTE até teste com Pro Controller real")
	lines.append("")
	if GameInput.is_pad_connected():
		lines.append("Device #%d: %s" % [GameInput.last_device_id, GameInput.last_device_name])
	else:
		lines.append("No gamepad connected")
	lines.append("")
	var axes := GameInput.get_raw_axis_snapshot()
	if not axes.is_empty():
		lines.append("Left stick X: %+0.3f  Y: %+0.3f" % [axes.left_x, axes.left_y])
		lines.append("Right stick X: %+0.3f  Y: %+0.3f" % [axes.right_x, axes.right_y])
	lines.append("Steer action: %+0.3f" % GameInput.get_steer())
	lines.append("Accelerate: %s  Brake: %s" % [GameInput.is_accelerating(), GameInput.is_braking()])
	lines.append("")
	lines.append("Mapped Nintendo A (accel) -> joy btn %d" % GameInput.nintendo_a_button)
	lines.append("Mapped Nintendo B (brake) -> joy btn %d" % GameInput.nintendo_b_button)
	lines.append("Mapped Nintendo + (pause) -> joy btn %d" % GameInput.nintendo_plus_button)
	lines.append("")
	var pressed := GameInput.get_pressed_buttons()
	if pressed.is_empty():
		lines.append("Buttons pressed: (none)")
	else:
		lines.append("Buttons pressed: %s" % str(pressed))
	var pads := Input.get_connected_joypads()
	lines.append("")
	lines.append("Connected pads: %s" % str(pads))
	for id in pads:
		lines.append("  #%d %s guid=%s" % [id, Input.get_joy_name(id), Input.get_joy_guid(id)])
	text.text = "\n".join(lines)
