extends Node
## Gamepad-first input. Nintendo Switch Pro physical labels are the contract;
## SDL/Godot often remap face buttons to Xbox positions, so defaults map:
##   physical Nintendo A (east) -> JOY_BUTTON_B
##   physical Nintendo B (south) -> JOY_BUTTON_A
##   physical +                 -> JOY_BUTTON_START
## Verify on device via Input Diag. COMPATIBILIDADE FÍSICA PENDENTE until owner tests.

signal device_changed(connected: bool, device_name: String)

var last_device_id: int = -1
var last_device_name: String = ""
var _pad_connected: bool = false

## Override after physical confirmation if needed.
var nintendo_a_button: int = JOY_BUTTON_B
var nintendo_b_button: int = JOY_BUTTON_A
var nintendo_plus_button: int = JOY_BUTTON_START


func _ready() -> void:
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_refresh_devices()


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_refresh_devices()


func _refresh_devices() -> void:
	var ids := Input.get_connected_joypads()
	if ids.is_empty():
		_pad_connected = false
		last_device_id = -1
		last_device_name = ""
		device_changed.emit(false, "")
		return
	_pad_connected = true
	last_device_id = ids[0]
	last_device_name = Input.get_joy_name(last_device_id)
	device_changed.emit(true, last_device_name)


func is_pad_connected() -> bool:
	return _pad_connected


func get_steer() -> float:
	## Analog proportional + digital D-pad/keyboard; clamp to [-1, 1].
	var analog := Input.get_axis("steer_left_analog", "steer_right_analog")
	if absf(analog) < GameParams.STEER_DEADZONE:
		analog = 0.0
	else:
		var sign_a := signf(analog)
		var mag := (absf(analog) - GameParams.STEER_DEADZONE) / (1.0 - GameParams.STEER_DEADZONE)
		analog = sign_a * clampf(mag, 0.0, 1.0)

	var digital := 0.0
	if Input.is_action_pressed("steer_left"):
		digital -= 1.0
	if Input.is_action_pressed("steer_right"):
		digital += 1.0

	return clampf(analog + digital, -1.0, 1.0)


func is_accelerating() -> bool:
	return Input.is_action_pressed("accelerate")


func is_braking() -> bool:
	return Input.is_action_pressed("brake")


func is_confirm_just_pressed() -> bool:
	return Input.is_action_just_pressed("confirm")


func is_pause_just_pressed() -> bool:
	return Input.is_action_just_pressed("pause")


func is_diag_just_pressed() -> bool:
	return Input.is_action_just_pressed("toggle_diag")


func get_raw_axis_snapshot(device: int = -1) -> Dictionary:
	if device < 0:
		device = last_device_id
	if device < 0:
		return {}
	return {
		"left_x": Input.get_joy_axis(device, JOY_AXIS_LEFT_X),
		"left_y": Input.get_joy_axis(device, JOY_AXIS_LEFT_Y),
		"right_x": Input.get_joy_axis(device, JOY_AXIS_RIGHT_X),
		"right_y": Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y),
	}


func get_pressed_buttons(device: int = -1) -> Array[int]:
	if device < 0:
		device = last_device_id
	var pressed: Array[int] = []
	if device < 0:
		return pressed
	for i in range(JOY_BUTTON_SDL_MAX):
		if Input.is_joy_button_pressed(device, i):
			pressed.append(i)
	return pressed
