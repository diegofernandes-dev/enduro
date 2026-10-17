extends CanvasLayer
## Marco A: instrument values are drawn in RoadView (Enduro panel).
## This layer only shows a tiny pad/dev hint so we don't look like a modern HUD.

@onready var hint_label: Label = $HintLabel

var _speed: float = 0.0
var _overtakes: int = 0


func _ready() -> void:
	# Hide legacy VBox if present in older scenes
	var margin := get_node_or_null("Margin")
	if margin:
		margin.visible = false


func set_stats(speed: float, overtakes: int, pad_name: String) -> void:
	_speed = speed
	_overtakes = overtakes
	if hint_label == null:
		return
	if pad_name.is_empty():
		hint_label.text = "kb"
	else:
		hint_label.text = "pad"


func set_visible_hud(v: bool) -> void:
	# Panel lives in the world view; keep this layer for optional diag hint only
	visible = v
	if hint_label:
		hint_label.visible = false ## silent during race — F1 for diag
