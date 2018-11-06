extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

onready var _background = get_node("MarginContainer/background")
onready var _timer = get_node("timeout")

func _ready():
	get_tree().get_root().connect("size_changed", self, "_resize")
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / head.NORMAL_WIDTH, size.y / head.NORMAL_HEIGHT)
	
	get_node("logout_warning").dialog_text = (
		"Are you sure you want to logout?  Your profile will be unusable,\n") + (
		"and you have to start from scratch to play again.")
	pass

func _process(delta):
	pass

func _input(event):
	if event is InputEventMouse:
		_timer.start()
	pass

func scene_change(button):
	match (button):
		"leader":
			get_tree().change_scene("res://Scenes/leaderboard.tscn")
		"custom":
			get_tree().change_scene("res://Scenes/build.tscn")
		"stats":
			get_tree().change_scene("res://Scenes/stats.tscn")
		"train":
			get_tree().change_scene("res://Scenes/arena_train.tscn")
		"fight":
			get_tree().change_scene("res://Scenes/arena_battle.tscn")
	pass

func _resize():
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / head.NORMAL_WIDTH, size.y / head.NORMAL_HEIGHT)
	pass

func screen_idle_timeout():
	var warning = get_node("timeout_warning")
	warning.popup()
	pass

func restart_timer():
	_timer.start()
	pass

func logout():
	get_node("logout_warning").popup()
	pass

func _on_logout_warning_confirmed():
	head.save_bots(head.bots)
	head.init_bots()
	get_tree().change_scene("res://Scenes/menu_title.tscn")
	pass
