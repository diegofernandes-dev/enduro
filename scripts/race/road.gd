class_name RoadSim
extends RefCounted
## Segment-based pseudo-3D road (Lou's / OutRun style). Simulation only.

class Segment:
	var index: int = 0
	var world_z: float = 0.0
	var curve: float = 0.0
	var y: float = 0.0
	## Projected screen cache filled by renderer.
	var screen_x: float = 0.0
	var screen_y: float = 0.0
	var screen_w: float = 0.0
	var clip: float = 0.0
	var scale: float = 0.0


var segments: Array[Segment] = []
var track_length: float = 0.0
var position_z: float = 0.0
var player_x: float = 0.0


func build() -> void:
	segments.clear()
	for i in range(GameParams.ROAD_SEGMENTS):
		var seg := Segment.new()
		seg.index = i
		seg.world_z = float(i) * GameParams.SEGMENT_LENGTH
		seg.curve = _curve_for_index(i)
		seg.y = 0.0
		segments.append(seg)
	track_length = float(segments.size()) * GameParams.SEGMENT_LENGTH
	position_z = 0.0


func _curve_for_index(i: int) -> float:
	## Mild repeating curves — empirical, not original ROM data.
	var t := float(i)
	var c := 0.0
	if i > 40 and i < 120:
		c = 2.2
	elif i > 160 and i < 240:
		c = -2.5
	elif i > 280 and i < 360:
		c = 1.8
	elif i > 400 and i < 470:
		c = -2.0
	# Soft edges
	var edge := 12.0
	if i > 40 and i < 40 + int(edge):
		c *= (t - 40.0) / edge
	elif i > 120 - int(edge) and i < 120:
		c *= (120.0 - t) / edge
	return c * GameParams.CURVE_STRENGTH


func advance(delta: float, speed: float, player_lateral: float) -> float:
	## Returns cumulative curve pull felt this frame (for camera sway).
	position_z = fposmod(position_z + speed * delta * 60.0, track_length)
	player_x = player_lateral
	var base := find_segment(position_z)
	return base.curve * speed * delta * 0.35


func find_segment(z: float) -> Segment:
	var idx := int(z / GameParams.SEGMENT_LENGTH) % segments.size()
	if idx < 0:
		idx += segments.size()
	return segments[idx]


func percent_remaining(z: float) -> float:
	return fposmod(z, GameParams.SEGMENT_LENGTH) / GameParams.SEGMENT_LENGTH
