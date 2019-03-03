extends Path2D

var text = "text" setget text_set, text_get
export(int, -1, 100) var max_chars = -1
export(int, -1, 1000) var box_width = -1
export(float, 0.0, 1000.0) var duration = 0.0
export(float, 0.0, 1000.0) var delay = 0.0
export(int, 0, 10) onready var transition_type = Tween.TRANS_CUBIC
export(int, 0, 3) onready var ease_type = Tween.EASE_OUT

func _ready():
	text_set(text)

func text_set(value):
	var button = get_node("PathFollow2D/Button")
	if max_chars != -1:
		value = value.left(max_chars)
	button.text = value
	text = value
	if box_width != -1:
		button.rect_size.x = box_width
func text_get():
	var button = get_node("PathFollow2D/Button")
	return button.text

func slide():
	var tween = Tween.new()
	tween.interpolate_property(get_child(0), ":unit_offset", 0.0, 1.0, duration, transition_type, ease_type, delay)
	add_child(tween)
	tween.start()
