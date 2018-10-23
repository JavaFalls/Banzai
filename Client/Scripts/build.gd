extends Node

const NORMAL_WIDTH = 1600
const NORMAL_HEIGHT = 900

onready var _background = get_node("Container/game_background_31")

func _ready():
	get_tree().get_root().connect("size_changed", self, "resize")
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / NORMAL_WIDTH, size.y / NORMAL_HEIGHT)
	pass

func resize():
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / NORMAL_WIDTH, size.y / NORMAL_HEIGHT)
	pass
