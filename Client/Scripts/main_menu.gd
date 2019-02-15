extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

onready var _background = get_node("Control/MarginContainer/background")
onready var _timer = get_node("timeout")
onready var _tween = get_node("Tween")

func _ready():
	get_node("logout_warning/Label").text = (
		"Are you sure you want to logout?  Your profile will be unusable, " +
		"and you have to start from scratch to play again.")
	get_node("logout_warning").connect("popup_hide", self, "unfade")
	get_node("logout_warning/button_face/Button").connect("mouse_entered", self, "hover_logout_confirm", [true])
	get_node("logout_warning/button_face/Button").connect("mouse_exited", self, "hover_logout_confirm", [false])
	
	get_node("Control/username").text = head.username
	pass

func _process(delta):
	pass

func _input(event):
	if event is InputEventMouse:
		_timer.start()
	pass

"""
Various nodes' signal methods
"""

func scene_change(button):
	match (button):
		"leader":
			get_tree().change_scene("res://Scenes/leaderboard.tscn")
		"custom":
			get_tree().change_scene("res://Scenes/build.tscn")
		"stats":
			get_tree().change_scene("res://Scenes/stats.tscn")
		"train":
			get_tree().change_scene("res://Scenes/Load_training.tscn")
		"fight":
			head.load_scene("res://Scenes/battle_arena.tscn")
	pass

func screen_idle_timeout():
	fade()
	get_node("logout_warning").hide()
	get_node("timeout_warning").popup()
	pass

func restart_timer():
	_timer.start()
	unfade()
	pass

func logout():
	fade()
	get_node("logout_warning").popup()
	pass

func hover_logout_confirm(mouse_entered):
	var tween = get_node("logout_warning/button_face/Tween")
	var panel = get_node("logout_warning/button_face/Panel")
	if mouse_entered:
		tween.interpolate_property(
			panel, "modulate:a",
			panel.modulate.a, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		tween.start()
	else:
		tween.interpolate_property(
			panel, "modulate:a",
			panel.modulate.a, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		tween.start()

func _on_logout_warning_confirmed():
#	head.save_bots(head.bots)
	head.init_bots()
	get_tree().change_scene("res://Scenes/menu_title.tscn")
	pass

"""
Node methods
"""

func fade():
	_tween.interpolate_property(
		get_node("Control"), "modulate",
		Color("#ffffff"), Color("#9b9b9b"), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	_tween.start()

func unfade():
	_tween.interpolate_property(
		get_node("Control"), "modulate",
		get_node("Control").modulate, Color("#ffffff"), 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	_tween.start()
