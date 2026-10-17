class_name PlayerVehicle
extends RefCounted
## Player speed and lateral position. Coasting: release accel keeps speed (manual).

var speed: float = 0.0
var position: float = 0.0 ## -1 .. 1 across road
var offroad: bool = false


func reset() -> void:
	speed = 0.0
	position = 0.0
	offroad = false


func update(delta: float, steer: float, accelerating: bool, braking: bool) -> void:
	if accelerating and not braking:
		speed = minf(speed + GameParams.ACCEL_RATE * delta, GameParams.MAX_SPEED)
	elif braking:
		speed = maxf(speed - GameParams.BRAKE_RATE * delta, 0.0)
	# else: coast — hold current speed (Activision manual)

	var steer_scale := 1.0
	if speed < 20.0:
		steer_scale = speed / 20.0
	position += steer * GameParams.STEER_RATE * steer_scale * delta

	offroad = absf(position) > GameParams.ROAD_HALF_WIDTH
	if offroad:
		speed = maxf(speed - GameParams.OFFROAD_DRAG * delta, 0.0)
		position = clampf(position, -1.15, 1.15)
	else:
		position = clampf(position, -GameParams.ROAD_HALF_WIDTH, GameParams.ROAD_HALF_WIDTH)


func apply_car_collision() -> void:
	speed *= GameParams.COLLISION_SPEED_FACTOR


func apply_roadside_nudge() -> void:
	speed *= GameParams.OFFROAD_SPEED_PENALTY
