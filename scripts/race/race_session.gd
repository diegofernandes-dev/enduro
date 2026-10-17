class_name RaceSession
extends RefCounted
## Marco A session: title / playing / paused. Full day rules come in Marco B.

enum State { TITLE, PLAYING, PAUSED }

signal state_changed(new_state: State)
signal overtake_count_changed(count: int)

var state: State = State.TITLE
var vehicle := PlayerVehicle.new()
var road := RoadSim.new()
var traffic := TrafficManager.new()
var overtake_count: int = 0
var curve_pull: float = 0.0


func _init() -> void:
	traffic.overtaken.connect(_on_overtaken)
	traffic.car_collision.connect(_on_car_collision)


func start_race() -> void:
	road.build()
	vehicle.reset()
	traffic.reset()
	overtake_count = 0
	curve_pull = 0.0
	_set_state(State.PLAYING)
	overtake_count_changed.emit(overtake_count)


func pause() -> void:
	if state == State.PLAYING:
		_set_state(State.PAUSED)


func resume() -> void:
	if state == State.PAUSED:
		_set_state(State.PLAYING)


func toggle_pause() -> void:
	if state == State.PLAYING:
		pause()
	elif state == State.PAUSED:
		resume()


func return_to_title() -> void:
	_set_state(State.TITLE)


func restart() -> void:
	start_race()


func update(delta: float, steer: float, accelerating: bool, braking: bool) -> void:
	if state != State.PLAYING:
		return
	vehicle.update(delta, steer, accelerating, braking)
	curve_pull = road.advance(delta, vehicle.speed, vehicle.position)
	traffic.update(delta, road.position_z, vehicle.position, vehicle.speed, road.track_length)


func _on_overtaken() -> void:
	overtake_count += 1
	overtake_count_changed.emit(overtake_count)


func _on_car_collision() -> void:
	vehicle.apply_car_collision()


func _set_state(s: State) -> void:
	state = s
	state_changed.emit(state)
