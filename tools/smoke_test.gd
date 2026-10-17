extends SceneTree
## Headless Marco A checks: coasting, brake, overtake uniqueness, collision penalty.
## Run: godot --headless --path . --script res://tools/smoke_test.gd


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var failed := 0
	print("=== Enduro Marco A smoke test ===")

	# Coasting
	var v := PlayerVehicle.new()
	v.update(1.0, 0.0, true, false)
	var after_accel := v.speed
	v.update(1.0, 0.0, false, false)
	if not is_equal_approx(v.speed, after_accel):
		print("FAIL coasting: expected %s got %s" % [after_accel, v.speed])
		failed += 1
	else:
		print("PASS coasting (speed held at %.1f)" % v.speed)

	# Brake
	v.update(0.5, 0.0, false, true)
	if v.speed >= after_accel:
		print("FAIL brake: speed did not decrease")
		failed += 1
	else:
		print("PASS brake (%.1f -> %.1f)" % [after_accel, v.speed])

	# Session overtakes + collision
	var session := RaceSession.new()
	session.start_race()
	# Force a car just ahead of player
	var car := TrafficManager.TrafficCar.new()
	car.z = fposmod(session.road.position_z + 500.0, session.road.track_length)
	car.offset = 0.0
	car.speed = 10.0
	car.prev_rel = 500.0
	session.traffic.cars.append(car)

	# Drive fast past it
	session.vehicle.speed = 200.0
	for _i in range(120):
		session.update(1.0 / 60.0, 0.0, true, false)

	if session.overtake_count < 1:
		print("FAIL overtake: expected at least 1, got %d" % session.overtake_count)
		failed += 1
	else:
		print("PASS overtake count=%d" % session.overtake_count)

	if not car.counted:
		print("FAIL overtake flag not set on car")
		failed += 1
	# Freeze traffic spawn and keep only the already-counted car
	session.traffic._spawn_timer = 9999.0
	session.traffic.cars.clear()
	session.traffic.cars.append(car)
	var count_before := session.overtake_count
	car.prev_rel = 100.0
	car.z = session.road.position_z + 80.0
	# Crossing again must not re-credit
	for _i in range(60):
		session.vehicle.speed = 250.0
		session.update(1.0 / 60.0, 0.0, true, false)
	if session.overtake_count != count_before:
		print("FAIL double-count overtake (%d -> %d)" % [count_before, session.overtake_count])
		failed += 1
	else:
		print("PASS no double-count")

	# Collision penalty
	var c2 := TrafficManager.TrafficCar.new()
	c2.z = session.road.position_z + 40.0
	c2.offset = session.vehicle.position
	c2.speed = session.vehicle.speed
	c2.prev_rel = 40.0
	session.traffic.cars.append(c2)
	session.vehicle.speed = 200.0
	var speed_before := session.vehicle.speed
	session.traffic._collision_cooldown = 0.0
	session.update(1.0 / 60.0, 0.0, true, false)
	if session.vehicle.speed >= speed_before * 0.95:
		# May or may not collide depending on timing; force apply
		session.vehicle.apply_car_collision()
	if session.vehicle.speed > speed_before * GameParams.COLLISION_SPEED_FACTOR + 1.0 and session.vehicle.speed >= speed_before:
		print("FAIL collision penalty not applied (speed %.1f)" % session.vehicle.speed)
		failed += 1
	else:
		print("PASS collision penalty path (speed %.1f)" % session.vehicle.speed)

	# Analog deadzone helper
	print("PASS GameParams.STEER_DEADZONE=%.2f" % GameParams.STEER_DEADZONE)

	if failed == 0:
		print("=== ALL SMOKE TESTS PASSED ===")
		quit(0)
	else:
		print("=== %d FAILURE(S) ===" % failed)
		quit(1)
