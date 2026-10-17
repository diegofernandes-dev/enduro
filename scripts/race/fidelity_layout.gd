class_name FidelityLayout
extends RefCounted
## Measured layout from docs/reference/enduro_day_ref_160.png
## (see docs/reference/REFERENCE.md). Values are pixel measurements, not guesses.

const WIDTH := 160
const HEIGHT := 192

const HORIZON_Y := 64
## Grass continues through y=150; black panel starts at 151 (measured).
const PLAY_BOTTOM_Y := 150
const PANEL_Y := 151

const COL_SKY := Color8(44, 58, 191)
const COL_GRASS := Color8(0, 57, 0)
const COL_BLACK := Color8(0, 0, 0)
const COL_LINE := Color8(232, 232, 232)
const COL_MOUNTAIN := Color8(196, 196, 196)
const COL_PLAYER := Color8(236, 236, 236)
const COL_PANEL_RED := Color8(188, 37, 30)
const COL_PANEL_TAN := Color8(206, 133, 65)
const COL_DIGIT := Color8(8, 8, 8)

## Red instrument bezel measured: x 42–108, y 157–180
const PANEL_BOX := Rect2i(42, 157, 67, 24)

## Mountain spans on horizon (y 60–63), measured bright clusters.
const MOUNTAIN_LEFT := [Vector2i(20, 63), Vector2i(26, 60), Vector2i(33, 60), Vector2i(48, 63)]
const MOUNTAIN_RIGHT := [Vector2i(96, 63), Vector2i(106, 60), Vector2i(114, 60), Vector2i(120, 63)]

## Measured left/right road edge x at selected scanlines (luminance peaks).
const ROAD_EDGE_SAMPLES := [
	[106, 59, 109],
	[113, 51, 110],
	[115, 48, 111],
	[120, 43, 112],
	[125, 38, 113],
	[130, 33, 115],
	[135, 29, 118],
	[140, 26, 120],
	[144, 23, 122],
	[148, 21, 124],
]

## Activision rainbow rows (y → RGB), measured from reference x≈12–32.
const RAINBOW_ROWS := {
	185: Color8(56, 2, 0),
	186: Color8(194, 85, 43),
	187: Color8(191, 120, 38),
	188: Color8(214, 208, 84),
	189: Color8(101, 144, 26),
	190: Color8(73, 107, 142),
	191: Color8(5, 12, 56),
}


static func road_half(t: float) -> float:
	return lerpf(1.5, 51.5, pow(clampf(t, 0.0, 1.0), 1.85))


static func road_mid(t: float, player_x: float, curve_amt: float) -> float:
	var tt := clampf(t, 0.0, 1.0)
	var base := 72.5 + curve_amt * (1.0 - tt) * (1.0 - tt) * 48.0
	return base - player_x * 40.0 * tt * tt


static func edge_at_y(y: int) -> Vector2i:
	var samples := ROAD_EDGE_SAMPLES
	if y <= int(samples[0][0]):
		return Vector2i(int(samples[0][1]), int(samples[0][2]))
	if y >= int(samples[samples.size() - 1][0]):
		var last: Array = samples[samples.size() - 1]
		return Vector2i(int(last[1]), int(last[2]))
	for i in range(samples.size() - 1):
		var a: Array = samples[i]
		var b: Array = samples[i + 1]
		var ya := int(a[0])
		var yb := int(b[0])
		if y >= ya and y <= yb:
			var u := float(y - ya) / float(yb - ya)
			return Vector2i(
				int(round(lerpf(float(a[1]), float(b[1]), u))),
				int(round(lerpf(float(a[2]), float(b[2]), u)))
			)
	return Vector2i(21, 124)
