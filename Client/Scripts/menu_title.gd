extends Node

onready var _macros = preload("res://Scripts/macros.gd")

onready var _manufacturor = get_node("VBoxContainer/HBoxContainer/manufacturor")
onready var _name = get_node("VBoxContainer/HBoxContainer/name")
onready var _code = get_node("VBoxContainer/HBoxContainer/code")

onready var _slider = get_node("VBoxContainer/HSlider")

onready var _background = get_node("MarginContainer/background")

func _ready():
	get_tree().get_root().connect("size_changed", self, "_resize")
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / _macros.NORMAL_WIDTH, size.y / _macros.NORMAL_HEIGHT)
	pass
	
func _process(delta):
#	get_tree().change_scene("res://Scenes/main_menu.tscn")
	pass
	
func _input(event):
	if event is InputEventKey and event.is_pressed():
		_slider.show()
		_manufacturor.popup()
		_name.popup()
		_code.popup()

func _resize():
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / _macros.NORMAL_WIDTH, size.y / _macros.NORMAL_HEIGHT)
	pass
