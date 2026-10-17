extends CanvasLayer
## Minimal 2600-style prompts — no modern rounded panels over the playfield.

enum Mode { HIDDEN, TITLE, PAUSED }

signal start_pressed
signal resume_pressed
signal restart_pressed
signal quit_to_title_pressed

@onready var panel: PanelContainer = $Center/Panel
@onready var title_label: Label = $Center/Panel/Margin/VBox/TitleLabel
@onready var body_label: Label = $Center/Panel/Margin/VBox/BodyLabel
@onready var action_label: Label = $Center/Panel/Margin/VBox/ActionLabel

var mode: Mode = Mode.HIDDEN
var _pause_index: int = 0
const PAUSE_OPTIONS := ["Resume", "Restart", "Title"]


func _ready() -> void:
	# Invisible chrome; race view stays pure. Pause still needs text.
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.75)
	style.set_corner_radius_all(0)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", style)


func show_title() -> void:
	## Title: hide overlay entirely — RoadView draws "PRESS A".
	mode = Mode.TITLE
	visible = false
	_pause_index = 0


func show_pause() -> void:
	mode = Mode.PAUSED
	visible = true
	panel.visible = true
	title_label.text = "PAUSED"
	body_label.text = "A select  + back"
	_pause_index = 0
	_refresh_pause_action()


func hide_overlay() -> void:
	mode = Mode.HIDDEN
	visible = false


func _refresh_pause_action() -> void:
	var lines: PackedStringArray = []
	for i in range(PAUSE_OPTIONS.size()):
		var prefix := ">" if i == _pause_index else " "
		lines.append(prefix + PAUSE_OPTIONS[i])
	action_label.text = "\n".join(lines)


func _process(_delta: float) -> void:
	if mode == Mode.TITLE:
		# Confirm still works while overlay is hidden
		if GameInput.is_confirm_just_pressed():
			start_pressed.emit()
		return
	if mode != Mode.PAUSED:
		return
	if Input.is_action_just_pressed("steer_up") or Input.is_action_just_pressed("ui_up"):
		_pause_index = (_pause_index - 1 + PAUSE_OPTIONS.size()) % PAUSE_OPTIONS.size()
		_refresh_pause_action()
	elif Input.is_action_just_pressed("steer_down") or Input.is_action_just_pressed("ui_down"):
		_pause_index = (_pause_index + 1) % PAUSE_OPTIONS.size()
		_refresh_pause_action()
	if GameInput.is_confirm_just_pressed():
		match _pause_index:
			0:
				resume_pressed.emit()
			1:
				restart_pressed.emit()
			2:
				quit_to_title_pressed.emit()
