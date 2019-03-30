extends Label

var head
var sound

export(float, 0.0, 5.0) var delay = 0.1
export(int, 1, 100) var step = 1
export(bool) var play_sound

var text_length = 0
var text_position = 0
var scroll_text = ""
var tick = 0.0
var tick_start = 0.0

signal scroll_finished

# Godot methods
#----------------------------------------
func _ready():
	if play_sound:
		head = get_tree().get_root().get_node("/root/head")
		sound = head.create_player("UI")
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
			
			if play_sound:
				head.play_stream(sound, head.sounds.TEXT_SCROLL)
	else:
		emit_signal("scroll_finished")
		set_process(false)

func _exit_tree():
	if typeof(sound) != TYPE_NIL:
		head.delete_player(sound)

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
