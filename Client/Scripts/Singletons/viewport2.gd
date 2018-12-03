# https://github.com/godotengine/godot/issues/6506

extends Node

onready var head = get_node("/root/head")

# don't forget to use stretch mode 'viewport' and aspect 'ignore'
onready var viewport = get_viewport()

func _ready():
	get_tree().connect("screen_resized", self, "_screen_resized")

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_1:
			resize_window(head.resolutions[0])
		if event.scancode == KEY_2:
			resize_window(head.resolutions[1])
		if event.scancode == KEY_3:
			resize_window(head.resolutions[2])
		if event.scancode == KEY_4:
			resize_window(head.resolutions[3])
		if event.scancode == KEY_5:
			resize_window(head.resolutions[4])
		if event.scancode == KEY_6:
			resize_window(head.resolutions[5])

func resize_window(res):
	var size = Vector2(res, int(res * head.NORMAL_HEIGHT / head.NORMAL_WIDTH))
	OS.set_window_size(size)

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
