extends Node2D
## Dynamic Enduro daytime renderer driven by measured FidelityLayout constants.
## No CRT banding, no invented HUD chrome, no modern styling.

const _FL := preload("res://scripts/race/fidelity_layout.gd")

var session: RaceSession
## When set, overrides live session poses for deterministic captures.
var fidelity_override: Dictionary = {}

var _blink_t: float = 0.0


func _process(delta: float) -> void:
	_blink_t += delta
	queue_redraw()


func _draw() -> void:
	if session == null:
		return
	var vs := get_viewport_rect().size
	var sx := vs.x / float(_FL.WIDTH)
	var sy := vs.y / float(_FL.HEIGHT)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(sx, sy))

	var L := _FL
	draw_rect(Rect2(0, 0, L.WIDTH, L.HORIZON_Y), L.COL_SKY)
	draw_rect(Rect2(0, L.HORIZON_Y, L.WIDTH, L.PLAY_BOTTOM_Y - L.HORIZON_Y + 1), L.COL_GRASS)
	draw_rect(Rect2(0, L.PANEL_Y, L.WIDTH, L.HEIGHT - L.PANEL_Y), L.COL_BLACK)

	_draw_mountains()

	var pos_z := 0.0
	var player_x := 0.0
	var curve := 1.0 ## daytime reference rightward bend
	var show_prompt := false
	var cars: Array = []
	var use_measured_road := false

	if not fidelity_override.is_empty():
		pos_z = float(fidelity_override.get("pos_z", 0.0))
		player_x = float(fidelity_override.get("player_x", 0.0))
		curve = float(fidelity_override.get("curve", 1.0))
		cars = fidelity_override.get("cars", [])
		use_measured_road = bool(fidelity_override.get("measured_road", true))
	elif session.state == RaceSession.State.TITLE or session.road.segments.is_empty():
		pos_z = _blink_t * 36.0
		show_prompt = true
	else:
		pos_z = session.road.position_z
		player_x = session.vehicle.position
		curve = _sample_curve(pos_z)

	if use_measured_road:
		_draw_road_edges_measured(pos_z)
	else:
		_draw_road_edges(pos_z, player_x, curve)

	if not fidelity_override.is_empty():
		for c in cars:
			_draw_car_at(int(c.x), int(c.y), int(c.scale), c.color)
		_draw_car_at(int(fidelity_override.get("player_px", 87)), 143, 5, L.COL_PLAYER)
	elif session.state != RaceSession.State.TITLE and not session.road.segments.is_empty():
		_draw_traffic(player_x, curve)
		var px := int(_FL.road_mid(1.0, player_x, curve))
		_draw_car_at(px, L.PLAY_BOTTOM_Y - 5, 5, L.COL_PLAYER)
	else:
		_draw_car_at(87, 143, 5, L.COL_PLAYER)
		if show_prompt and int(_blink_t * 2.0) % 2 == 0:
			_draw_pixel_text(50, 98, "PRESS A", L.COL_LINE)

	_draw_panel()


func _draw_mountains() -> void:
	_fill_mountain_poly(_FL.MOUNTAIN_LEFT)
	_fill_mountain_poly(_FL.MOUNTAIN_RIGHT)


func _fill_mountain_poly(pts: Array) -> void:
	## Fill measured mountain silhouette as stacked horizontal spans.
	var y0 := int(pts[0].y)
	var y_peak := y0
	for p in pts:
		y_peak = mini(y_peak, int(p.y))
	for y in range(y_peak, _FL.HORIZON_Y):
		var xs: Array[int] = []
		for i in range(pts.size() - 1):
			var a: Vector2i = pts[i]
			var b: Vector2i = pts[i + 1]
			if (a.y <= y and b.y >= y) or (b.y <= y and a.y >= y):
				if a.y == b.y:
					xs.append(a.x)
					xs.append(b.x)
				else:
					var u := float(y - a.y) / float(b.y - a.y)
					xs.append(int(round(lerpf(float(a.x), float(b.x), u))))
		if xs.is_empty():
			continue
		xs.sort()
		draw_rect(Rect2(xs[0], y, xs[xs.size() - 1] - xs[0] + 1, 1), _FL.COL_MOUNTAIN)


func _draw_road_edges_measured(_pos_z: float) -> void:
	## Continuous white edges from measured scanlines (Enduro daytime reference).
	var L := _FL
	for y in range(L.HORIZON_Y + 2, L.PLAY_BOTTOM_Y + 1):
		var t := float(y - L.HORIZON_Y) / float(L.PLAY_BOTTOM_Y - L.HORIZON_Y)
		var edge := _FL.edge_at_y(y)
		if y < int(L.ROAD_EDGE_SAMPLES[0][0]):
			var u := float(y - L.HORIZON_Y) / float(int(L.ROAD_EDGE_SAMPLES[0][0]) - L.HORIZON_Y)
			var mid := lerpf(104.0, float(edge.x + edge.y) * 0.5, u)
			var half := lerpf(1.5, float(edge.y - edge.x) * 0.5, u * u)
			edge = Vector2i(int(mid - half), int(mid + half))
		## Reference edges are 1px (occasionally 2 near camera from JPEG bleed).
		_plot_edge(edge.x, y, 1)
		_plot_edge(edge.y, y, 1)


func _draw_road_edges(_pos_z: float, player_x: float, curve: float) -> void:
	var L := _FL
	for y in range(L.HORIZON_Y + 1, L.PLAY_BOTTOM_Y + 1):
		var t := float(y - L.HORIZON_Y) / float(L.PLAY_BOTTOM_Y - L.HORIZON_Y)
		var half := _FL.road_half(t)
		var mid := _FL.road_mid(t, player_x, curve)
		var lx := int(mid - half)
		var rx := int(mid + half)
		_plot_edge(lx, y, 1)
		_plot_edge(rx, y, 1)


func _plot_edge(x: int, y: int, thick: int) -> void:
	if x < 0 or x >= _FL.WIDTH:
		return
	draw_rect(Rect2(x, y, thick, 1), _FL.COL_LINE)


func _sample_curve(pos_z: float) -> float:
	if session.road.segments.is_empty():
		return 1.0
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
	var L := _FL
	for car in cars:
		var rel := _rel_z(car.z)
		if rel < 60.0 or rel > GameParams.SEGMENT_LENGTH * 75.0:
			continue
		var depth_t := clampf(1.0 - (rel / (GameParams.SEGMENT_LENGTH * 70.0)), 0.0, 1.0)
		var t := depth_t * depth_t
		var sy := int(lerpf(float(L.HORIZON_Y + 4), float(L.PLAY_BOTTOM_Y - 8), t))
		var half := _FL.road_half(t)
		var mid := _FL.road_mid(t, player_x, curve)
		var cx := int(mid + car.offset * half * 0.75)
		var scale := clampi(int(lerpf(1.0, 5.0, t)), 1, 5)
		_draw_car_at(cx, sy, scale, car.color)


func _rel_z(car_z: float) -> float:
	return session.traffic.relative_z(car_z, session.road.position_z, session.road.track_length)


func _draw_car_at(cx: int, bottom_y: int, scale: int, col: Color) -> void:
	## Full-size silhouette measured from enduro_day_ref_160.png (bbox 79–94 × 135–143).
	var rows: Array[String]
	if scale >= 5:
		## Cleaned measured silhouette (JPEG speckles removed).
		rows = [
			"01100111100110",
			"01111111111110",
			"01100111100110",
			"11011111111101",
			"01111111111110",
			"00011111111000",
			"00011111111000",
			"01111111111110",
			"11000000000011",
		]
	else:
		match clampi(scale, 1, 4):
			1:
				rows = ["11", "11"]
			2:
				rows = ["0110", "1111", "1111"]
			3:
				rows = ["0011100", "0111110", "1111111", "0111110"]
			_:
				## Near opponent ~10×6 from reference yellow car.
				rows = [
					"0011111000",
					"0111111100",
					"0111111100",
					"1111111111",
					"0111111110",
					"0001111000",
				]
	var top := bottom_y - rows.size() + 1
	for ri in range(rows.size()):
		var row: String = rows[ri]
		var x0 := cx - row.length() / 2
		for ci in range(row.length()):
			if row[ci] == "1":
				draw_rect(Rect2(x0 + ci, top + ri, 1, 1), col)


func _draw_panel() -> void:
	var L := _FL
	draw_rect(Rect2(0, L.PANEL_Y, L.WIDTH, L.HEIGHT - L.PANEL_Y), L.COL_BLACK)
	var box := L.PANEL_BOX
	## Reference instrument is predominantly red with black digits (tan only as
	## mid-tone JPEG average of orange-red); fill solid red like the TIA look.
	draw_rect(Rect2(box), L.COL_PANEL_RED)

	var km := 0
	var day := 1
	var cars_left := 200
	if not fidelity_override.is_empty():
		km = int(fidelity_override.get("km", 970))
		day = int(fidelity_override.get("day", 6))
		cars_left = int(fidelity_override.get("cars_left", 208))
	elif session != null:
		km = int(session.road.position_z / 80.0) % 10000
		day = 1
		cars_left = maxi(0, 200 - session.overtake_count)

	## Digit positions from dark-pixel clusters in the reference panel.
	## Top row ≈ y160–164 @ x60+; bottom ≈ y172–177 @ x51+.
	_draw_digits(60, 160, "%04d" % km, 1)
	_draw_dual_car_icon(93, 160)

	_draw_digits(51, 172, "%d" % day, 1)
	_draw_panel_mark(66, 172)
	_draw_digits(78, 172, "%03d" % cars_left, 1)

	_draw_rainbow()
	_draw_pixel_text(34, 186, "ACTIVISION", Color8(230, 230, 230))


func _draw_digits(x: int, y: int, text: String, px: int) -> void:
	var cursor := x
	for i in range(text.length()):
		cursor += _draw_digit(cursor, y, text[i], px) + px


func _draw_digit(x: int, y: int, ch: String, px: int) -> int:
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
				draw_rect(Rect2(x + col * px, y + row * px, px, px), _FL.COL_DIGIT)
	return 3 * px


func _draw_dual_car_icon(x: int, y: int) -> void:
	## Two tiny side-by-side cars as on the reference top row.
	draw_rect(Rect2(x, y + 1, 5, 3), _FL.COL_DIGIT)
	draw_rect(Rect2(x + 1, y, 3, 1), _FL.COL_DIGIT)
	draw_rect(Rect2(x + 7, y + 1, 5, 3), _FL.COL_DIGIT)
	draw_rect(Rect2(x + 8, y, 3, 1), _FL.COL_DIGIT)


func _draw_panel_mark(x: int, y: int) -> void:
	## Trophy glyph beside cars-remaining (measured role in the instrument panel).
	draw_rect(Rect2(x + 1, y, 5, 1), _FL.COL_DIGIT)
	draw_rect(Rect2(x, y + 1, 7, 3), _FL.COL_DIGIT)
	draw_rect(Rect2(x + 2, y + 4, 3, 2), _FL.COL_DIGIT)
	draw_rect(Rect2(x + 1, y + 6, 5, 1), _FL.COL_DIGIT)


func _draw_rainbow() -> void:
	## Measured Activision rainbow bar: x 12–32, y 185–191 (one color per row).
	for y in _FL.RAINBOW_ROWS.keys():
		draw_rect(Rect2(12, int(y), 21, 1), _FL.RAINBOW_ROWS[y])


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
