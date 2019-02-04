extends Path2D

export(float, 0.0, 1000.0) var duration = 0.0
export(float, 0.0, 1000.0) var delay = 0.0
export(int, 0, 10) onready var transition_type = Tween.TRANS_CUBIC
export(int, 0, 3) onready var ease_type = Tween.EASE_OUT

export(Theme) var theme

func _ready():
	get_node("PathFollow2D/Button").theme = theme

func slide():
	var tween = Tween.new()
	tween.interpolate_property(get_child(0), ":unit_offset", 0.0, 1.0, duration, transition_type, ease_type, delay)
	add_child(tween)
	tween.start()
