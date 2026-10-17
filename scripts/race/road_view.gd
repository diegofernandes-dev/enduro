extends Node2D
## Enduro daytime look tuned for 1980s Atari 2600 “feel”:
## chunky stair-step road edges, solid sprites, thick panel digits, subtle TIA banding.
## ROM pixels not copied — matched from reference screenshots.

var session: RaceSession
var _blink_t: float = 0.0

const COL_SKY := Color("2C3ABF")
const COL_GRASS := Color("003900")
const COL_LINE := Color("ECECEC")
const COL_MOUNTAIN := Color("C8C8C8")
const COL_PLAYER := Color("E8E8E8")
const COL_BLACK := Color("000000")
const COL_PANEL_RED := Color("BE2517")
const COL_PANEL_TAN := Color("C8A040")
const COL_DIGIT := Color("080808")

const W := 160
const H := 192
const HORIZON := 66
const PLAY_BOTTOM := 146
const PANEL_Y := 150


func _process(delta: float) -> void:
	_blink_t += delta
	queue_redraw()


func _draw() -> void:
	if session == null:
		return
	var vs := get_viewport_rect().size
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(vs.x / float(W), vs.y / float(H)))

	draw_rect(Rect2(0, 0, W, HORIZON), COL_SKY)
	draw_rect(Rect2(0, HORIZON, W, PLAY_BOTTOM - HORIZON + 1), COL_GRASS)
	draw_rect(Rect2(0, PANEL_Y, W, H - PANEL_Y), COL_BLACK)

	# Subtle TIA-style even-line darkening (not a modern CRT shader)
	for y in range(0, PLAY_BOTTOM, 2):
		draw_rect(Rect2(0, y, W, 1), Color(0, 0, 0, 0.12))

	_draw_mountains()

	var pos_z := 0.0
	var player_x := 0.0
	var curve := 0.35 ## idle show a gentle curve like reference
	var playing := session.state != RaceSession.State.TITLE and not session.road.segments.is_empty()
	if playing:
		pos_z = session.road.position_z
		player_x = session.vehicle.position
		curve = _sample_curve(pos_z)
	else:
		pos_z = _blink_t * 40.0 ## animate dashes on title

	_draw_road_edges(pos_z, player_x, curve)

	if playing:
		_draw_traffic(player_x, curve)
		_draw_player(player_x)
	else:
		_draw_car_pixels(80, PLAY_BOTTOM - 1, 5, COL_PLAYER)
		# Blink like old coin-ops / 2600 attract modes
		if int(_blink_t * 2.0) % 2 == 0:
			_draw_pixel_text(50, 98, "PRESS A", COL_LINE)

	_draw_panel()


func _draw_mountains() -> void:
	## Low, asymmetric white ranges sitting on the horizon (reference).
	_range(12, [3, 5, 8, 6, 4, 2])
	_range(105, [2, 4, 7, 9, 5, 3, 2])


func _range(x0: int, heights: Array) -> void:
	var x := x0
	for h in heights:
		var hh: int = int(h)
		for row in range(hh):
			var half := (row * 2) / maxi(hh, 1) + 1
			var y := HORIZON - hh + row
			draw_rect(Rect2(x - half, y, half * 2 + 1, 1), COL_MOUNTAIN)
		x += hh + 2


func _draw_road_edges(pos_z: float, player_x: float, curve: float) -> void:
	## Chunky stair-step borders — hallmark of 2600 pseudo-3D roads.
	## Draw as short horizontal “bricks”, not thin anti-aliased diagonals.
	var prev_lx := -1
	var prev_rx := -1
	for y in range(HORIZON + 1, PLAY_BOTTOM + 1):
		var t := float(y - HORIZON) / float(PLAY_BOTTOM - HORIZON)
		var persp := t * t
		var road_half := lerpf(2.0, 74.0, persp)
		var bend := curve * (1.0 - t) * t * 60.0
		var mid := 80.0 - player_x * 40.0 * persp + bend
		var lx := int(mid - road_half)
		var rx := int(mid + road_half)

		# Segment pattern scrolls with travel; denser near camera
		var brick_h := 1
		if persp > 0.55:
			brick_h = 2
		elif persp > 0.3:
			brick_h = 1

		var period := 5
		if persp > 0.7:
			period = 2
		elif persp > 0.4:
			period = 3
		var phase := int(pos_z * 0.22 + float(PLAY_BOTTOM - y) * 0.5)
		var on := (phase % period) <= (1 if persp > 0.35 else 0)
		# Near bottom always nearly solid
		if persp > 0.75:
			on = true

		if on:
			var thick := 2 if persp > 0.35 else 1
			# Stair-step: hold X until it jumps (classic jagged diagonal)
			if prev_lx < 0 or absi(lx - prev_lx) >= 1:
				prev_lx = lx
			if prev_rx < 0 or absi(rx - prev_rx) >= 1:
				prev_rx = rx
			_brick(prev_lx, y, thick, brick_h)
			_brick(prev_rx - thick + 1, y, thick, brick_h)


func _brick(x: int, y: int, w: int, h: int) -> void:
	if x < 0 or x >= W or y < HORIZON or y > PLAY_BOTTOM:
		return
	draw_rect(Rect2(x, y, mini(w, W - x), mini(h, PLAY_BOTTOM - y + 1)), COL_LINE)


func _sample_curve(pos_z: float) -> float:
	if session.road.segments.is_empty():
		return 0.0
	var base := session.road.find_segment(pos_z)
	var c := 0.0
	for n in range(1, 35):
		var seg: RoadSim.Segment = session.road.segments[(base.index + n) % session.road.segments.size()]
		c += seg.curve
	return clampf(c * 90.0, -1.4, 1.4)


func _draw_traffic(player_x: float, curve: float) -> void:
	var cars := session.traffic.get_active_cars()
	cars.sort_custom(func(a: TrafficManager.TrafficCar, b: TrafficManager.TrafficCar) -> bool:
		return _rel_z(a.z) > _rel_z(b.z)
	)
	for car in cars:
		var rel := _rel_z(car.z)
		if rel < 60.0 or rel > GameParams.SEGMENT_LENGTH * 75.0:
			continue
		var depth_t := clampf(1.0 - (rel / (GameParams.SEGMENT_LENGTH * 70.0)), 0.0, 1.0)
		var persp := depth_t * depth_t
		var sy := int(lerpf(float(HORIZON + 4), float(PLAY_BOTTOM - 8), persp))
		var road_half := lerpf(2.0, 74.0, persp)
		var bend := curve * (1.0 - depth_t) * depth_t * 50.0
		var mid := 80.0 - player_x * 40.0 * persp + bend
		var cx := int(mid + car.offset * road_half * 0.75)
		var scale := clampi(int(lerpf(1.0, 5.0, persp)), 1, 5)
		_draw_car_pixels(cx, sy, scale, car.color)


func _rel_z(car_z: float) -> float:
	return session.traffic.relative_z(car_z, session.road.position_z, session.road.track_length)


func _draw_player(player_x: float) -> void:
	_draw_car_pixels(int(80.0 + player_x * 36.0), PLAY_BOTTOM - 1, 5, COL_PLAYER)


func _draw_car_pixels(cx: int, bottom_y: int, scale: int, col: Color) -> void:
	## Wide formula silhouette drawn as solid pixels (no texture filter blur).
	var rows: Array[String]
	match clampi(scale, 1, 5):
		1:
			rows = ["111", "111"]
		2:
			rows = ["01110", "11111", "11111", "10101"]
		3:
			rows = ["00111100", "01111110", "11111111", "01111110", "11011011", "01111110"]
		4:
			rows = [
				"00011111000",
				"00111111100",
				"01111111110",
				"00111111100",
				"01101101110",
				"00111111100",
				"01101101110",
				"00111111100",
			]
		_:
			rows = [
				"000111111000",
				"001111111100",
				"011111111110",
				"001111111100",
				"011011110110",
				"001111111100",
				"011011110110",
				"001111111100",
				"011011110110",
				"000111111000",
			]
	var top := bottom_y - rows.size()
	for ri in range(rows.size()):
		var row: String = rows[ri]
		var x0 := cx - row.length() / 2
		for ci in range(row.length()):
			if row[ci] == "1":
				draw_rect(Rect2(x0 + ci, top + ri, 1, 1), col)


func _draw_panel() -> void:
	draw_rect(Rect2(0, PANEL_Y, W, H - PANEL_Y), COL_BLACK)

	var box_x := 24
	var box_y := PANEL_Y + 3
	var box_w := 112
	var box_h := 26
	# Thick red bezel like the reference
	draw_rect(Rect2(box_x, box_y, box_w, box_h), COL_PANEL_RED)
	draw_rect(Rect2(box_x + 3, box_y + 2, box_w - 6, box_h - 4), COL_PANEL_TAN)

	var km := 0
	var day := 1
	var cars_left := 200
	if session != null:
		km = int(session.road.position_z / 80.0) % 10000
		cars_left = maxi(0, 200 - session.overtake_count)

	# Thick 2600-style digits (px=2 → chunky)
	_draw_digits(box_x + 8, box_y + 4, "%04d" % km, 2)
	_draw_mini_car(box_x + 78, box_y + 4)
	_draw_digits(box_x + 92, box_y + 4, "1", 2)

	_draw_digits(box_x + 8, box_y + 15, "%d" % day, 2)
	_draw_trophy(box_x + 28, box_y + 14)
	_draw_digits(box_x + 48, box_y + 15, "%03d" % cars_left, 2)

	_draw_rainbow(4, H - 9)
	_draw_pixel_text(26, H - 10, "ACTIVISION", Color("F0F0F0"))


func _draw_digits(x: int, y: int, text: String, px: int) -> void:
	var cursor := x
	for i in range(text.length()):
		cursor += _draw_digit(cursor, y, text[i], px) + px


func _draw_digit(x: int, y: int, ch: String, px: int) -> int:
	## Extra-bold 3x5 digits for 80s instrument cluster look.
	var glyphs := {
		"0": ["111", "101", "101", "101", "111"],
		"1": ["010", "110", "010", "010", "111"],
		"2": ["111", "001", "111", "100", "111"],
		"3": ["111", "001", "111", "001", "111"],
		"4": ["101", "101", "111", "001", "001"],
		"5": ["111", "100", "111", "001", "111"],
		"6": ["111", "100", "111", "101", "111"],
		"7": ["111", "001", "001", "001", "001"],
		"8": ["111", "101", "111", "101", "111"],
		"9": ["111", "101", "111", "001", "111"],
	}
	var g: Array = glyphs.get(ch, glyphs["0"])
	for row in range(g.size()):
		var s: String = g[row]
		for col in range(s.length()):
			if s[col] == "1":
				draw_rect(Rect2(x + col * px, y + row * px, px, px), COL_DIGIT)
	return 3 * px


func _draw_mini_car(x: int, y: int) -> void:
	draw_rect(Rect2(x + 1, y, 6, 2), COL_DIGIT)
	draw_rect(Rect2(x, y + 2, 8, 3), COL_DIGIT)
	draw_rect(Rect2(x + 1, y + 5, 6, 1), COL_DIGIT)


func _draw_trophy(x: int, y: int) -> void:
	draw_rect(Rect2(x + 1, y, 5, 1), COL_DIGIT)
	draw_rect(Rect2(x, y + 1, 7, 3), COL_DIGIT)
	draw_rect(Rect2(x + 2, y + 4, 3, 2), COL_DIGIT)
	draw_rect(Rect2(x + 1, y + 6, 5, 1), COL_DIGIT)


func _draw_rainbow(x: int, y: int) -> void:
	var colors := [
		Color("AA44CC"), Color("4466EE"), Color("22CC44"),
		Color("EEEE22"), Color("EE8822"), Color("EE2222"),
	]
	for i in range(colors.size()):
		draw_rect(Rect2(x, y + i, 20, 1), colors[i])


func _draw_pixel_text(x: int, y: int, text: String, col: Color) -> void:
	var cursor := x
	for i in range(text.length()):
		var ch := text[i]
		if ch == " ":
			cursor += 4
			continue
		cursor += _draw_letter(cursor, y, ch, col) + 1


func _draw_letter(x: int, y: int, ch: String, col: Color) -> int:
	var g := {
		"A": ["010", "101", "111", "101", "101"],
		"C": ["111", "100", "100", "100", "111"],
		"E": ["111", "100", "111", "100", "111"],
		"I": ["111", "010", "010", "010", "111"],
		"N": ["101", "111", "111", "101", "101"],
		"O": ["111", "101", "101", "101", "111"],
		"P": ["111", "101", "111", "100", "100"],
		"R": ["111", "101", "111", "110", "101"],
		"S": ["111", "100", "111", "001", "111"],
		"T": ["111", "010", "010", "010", "010"],
		"V": ["101", "101", "101", "101", "010"],
	}
	var rows: Array = g.get(ch, ["111", "101", "101", "101", "111"])
	for row in range(rows.size()):
		var s: String = rows[row]
		for c in range(s.length()):
			if s[c] == "1":
				draw_rect(Rect2(x + c, y + row, 1, 1), col)
	return 3
