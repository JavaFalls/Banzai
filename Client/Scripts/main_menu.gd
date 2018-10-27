extends Node

onready var _macros = preload("res://Scripts/macros.gd")
onready var _background = get_node("MarginContainer/background")
onready var _timer = get_node("timeout")

func _ready():
	get_tree().get_root().connect("size_changed", self, "_resize")
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / _macros.NORMAL_WIDTH, size.y / _macros.NORMAL_HEIGHT)
	pass

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene("res://Scenes/menu_title.tscn")
	pass

func _input(event):
	if event is InputEventMouse:
		_timer.start()
	pass

func _on_train_button_pressed():
	get_tree().change_scene("res://Scenes/build.tscn")
	pass

func _on_fight_button_pressed():
	get_tree().change_scene("res://Scenes/arena_battle.tscn")
	pass

func _resize():
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / _macros.NORMAL_WIDTH, size.y / _macros.NORMAL_HEIGHT)
	pass

func screen_idle_timeout():
	var warning = get_node("timeout_warning")
	warning.popup()
	pass

func restart_timer():
	_timer.start()
	pass
