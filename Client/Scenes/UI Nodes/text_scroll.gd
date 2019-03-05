extends Label

export(float, 0.0, 5.0) var delay = 0.1
export(int, 1, 100) var step = 1

var text_length = 0
var text_position = 0
var scroll_text = ""
var tick = 0.0
var tick_start = 0.0

signal scroll_finished

# Godot methods
#----------------------------------------
func _ready():
	set_process(false)

func _process(delta):
	if text_position < text_length:
		tick += delta
		if tick - tick_start >= delay:
			
			# Skip spaces
			while scroll_text.substr(text_position, 1) == " ":
				text += scroll_text.substr(text_position, 1)
				text_position += step
			
			text += scroll_text.substr(text_position, step)
			text_position += step
			tick = 0.0
			tick_start = 0.0
	else:
		emit_signal("scroll_finished")
		set_process(false)

# Text scrolling
#----------------------------------------
func scroll(p_text):
	if typeof(p_text) == TYPE_STRING:
		text_position = 0
		text_length = p_text.length()
		scroll_text = p_text
		text = ""
		tick = 0.0
		tick_start = 0.0
		set_process(true)
