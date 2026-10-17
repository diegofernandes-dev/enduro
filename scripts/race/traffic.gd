class_name TrafficManager
extends RefCounted
## Opponent cars in world depth. Overtakes counted once; collisions are not overtakes.

signal overtaken
signal car_collision

class TrafficCar:
	var z: float = 0.0
	var offset: float = 0.0 ## -1 .. 1
	var speed: float = 0.0
	var color: Color = Color.WHITE
	var counted: bool = false
	var active: bool = true
	var prev_rel: float = 9999.0


var cars: Array[TrafficCar] = []
var _spawn_timer: float = 0.0
var _rng := RandomNumberGenerator.new()
var _collision_cooldown: float = 0.0


func reset(seed_value: int = 0) -> void:
	cars.clear()
	_spawn_timer = 0.4
	_collision_cooldown = 0.0
	if seed_value != 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()


func update(delta: float, player_z: float, player_x: float, player_speed: float, track_length: float) -> void:
	_collision_cooldown = maxf(_collision_cooldown - delta, 0.0)
	_spawn_timer -= delta
	if _spawn_timer <= 0.0 and _active_count() < GameParams.TRAFFIC_MAX_ACTIVE:
		_spawn(player_z, player_speed, track_length)
		_spawn_timer = GameParams.TRAFFIC_SPAWN_INTERVAL * _rng.randf_range(0.7, 1.4)

	for car in cars:
		if not car.active:
			continue
		car.z += car.speed * delta * 60.0
		# Keep relative world wrapping with player reference frame handled by road z.
		var rel := relative_z(car.z, player_z, track_length)
		# Behind player and far: despawn (no overtake credit)
		if rel < -GameParams.SEGMENT_LENGTH * 8.0:
			car.active = false
			continue
		# Ahead too far: despawn
		if rel > GameParams.SEGMENT_LENGTH * float(GameParams.DRAW_DISTANCE):
			car.active = false
			continue

		# Overtake once when relative depth crosses from ahead to behind without a hit credit.
		if not car.counted and car.prev_rel > 0.0 and rel <= 0.0:
			if absf(car.offset - player_x) < 1.2:
				car.counted = true
				overtaken.emit()
		car.prev_rel = rel

		# Collision near player plane
		if _collision_cooldown <= 0.0 and absf(rel) < 100.0:
			if absf(car.offset - player_x) < 0.28:
				_collision_cooldown = GameParams.COLLISION_COOLDOWN
				car_collision.emit()
				car.offset += 0.35 if car.offset >= player_x else -0.35
				car.offset = clampf(car.offset, -0.9, 0.9)
				# Do not count this car as overtaken if we hit it
				car.counted = true


func get_active_cars() -> Array[TrafficCar]:
	var out: Array[TrafficCar] = []
	for c in cars:
		if c.active:
			out.append(c)
	return out


func _active_count() -> int:
	var n := 0
	for c in cars:
		if c.active:
			n += 1
	return n


func _spawn(player_z: float, player_speed: float, track_length: float) -> void:
	var car := TrafficCar.new()
	var ahead := GameParams.SEGMENT_LENGTH * float(_rng.randi_range(40, 90))
	car.z = fposmod(player_z + ahead, track_length)
	var lanes: Array = GameParams.TRAFFIC_LANE_POSITIONS
	car.offset = float(lanes[_rng.randi_range(0, lanes.size() - 1)])
	var factor := _rng.randf_range(GameParams.TRAFFIC_MIN_SPEED_FACTOR, GameParams.TRAFFIC_MAX_SPEED_FACTOR)
	car.speed = maxf(player_speed * factor, 40.0)
	# Daytime opponents from reference: yellow, blue, orange (flat single color)
	car.color = [
		Color("C8A030"), ## yellow/tan
		Color("2C48C8"), ## blue
		Color("C05018"), ## orange
		Color("C8A030"),
		Color("2C48C8"),
	][_rng.randi_range(0, 4)]
	cars.append(car)


func relative_z(car_z: float, player_z: float, track_length: float) -> float:
	var d := car_z - player_z
	if d > track_length * 0.5:
		d -= track_length
	elif d < -track_length * 0.5:
		d += track_length
	return d
