extends Node
## Main loop: titles, race, pause, optional input diag.

@onready var road_view: Node2D = $World/RoadView
@onready var hud: CanvasLayer = $HUD
@onready var overlay: CanvasLayer = $TitlePause
@onready var diag: CanvasLayer = $InputDiag

var session := RaceSession.new()


func _ready() -> void:
	road_view.session = session
	hud.set_visible_hud(false)
	diag.visible = false
	overlay.start_pressed.connect(_on_start)
	overlay.resume_pressed.connect(_on_resume)
	overlay.restart_pressed.connect(_on_restart)
	overlay.quit_to_title_pressed.connect(_on_quit_title)
	session.state_changed.connect(_on_state_changed)
	session.overtake_count_changed.connect(_on_overtakes)
	GameInput.device_changed.connect(_on_device_changed)
	_ensure_title()
	print("Enduro Marco A ready. Godot ", Engine.get_version_info())


func _physics_process(delta: float) -> void:
	if GameInput.is_diag_just_pressed():
		diag.visible = not diag.visible

	match session.state:
		RaceSession.State.TITLE:
			# Overlay may be hidden (2600-style); still accept confirm here.
			if GameInput.is_confirm_just_pressed():
				_on_start()
		RaceSession.State.PLAYING:
			if GameInput.is_pause_just_pressed():
				session.pause()
				overlay.show_pause()
			else:
				session.update(delta, GameInput.get_steer(), GameInput.is_accelerating(), GameInput.is_braking())
				_update_hud()
		RaceSession.State.PAUSED:
			if GameInput.is_pause_just_pressed():
				_on_resume()


func _on_start() -> void:
	session.start_race()
	overlay.hide_overlay()
	hud.set_visible_hud(true)
	_update_hud()


func _ensure_title() -> void:
	hud.set_visible_hud(false)
	overlay.show_title()


func _on_resume() -> void:
	session.resume()
	overlay.hide_overlay()


func _on_restart() -> void:
	session.restart()
	overlay.hide_overlay()
	hud.set_visible_hud(true)
	_update_hud()


func _on_quit_title() -> void:
	session.return_to_title()
	hud.set_visible_hud(false)
	overlay.show_title()


func _on_state_changed(_s: RaceSession.State) -> void:
	_update_hud()


func _on_overtakes(_c: int) -> void:
	_update_hud()


func _on_device_changed(_connected: bool, _name: String) -> void:
	_update_hud()


func _update_hud() -> void:
	hud.set_stats(session.vehicle.speed, session.overtake_count, GameInput.last_device_name)
