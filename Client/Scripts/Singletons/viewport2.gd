# https://github.com/godotengine/godot/issues/6506

extends Node

# don't forget to use stretch mode 'viewport' and aspect 'ignore'
onready var viewport = get_viewport()

func _ready():
	get_tree().connect("screen_resized", self, "_screen_resized")

func _screen_resized():
	var window_size = OS.get_window_size()
	
	var scale_x = window_size.x / viewport.size.x
	var scale_y = window_size.y / viewport.size.y
	
	var scale = min(scale_x, scale_y)
	
	# find the coordinate we will use to center the viewport inside the window
	var diff = window_size - (viewport.size * scale)
	var diffhalf = (diff * 0.5)
	
	# attach the viewport to the rect we calculated
	viewport.set_attach_to_screen_rect(Rect2(diffhalf, viewport.size * scale))
