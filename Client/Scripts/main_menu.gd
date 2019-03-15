extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

onready var _background = get_node("Control/MarginContainer/background")
onready var _timer = get_node("timeout")
onready var _tween = get_node("Tween")
onready var _bot = $animation_bot

var ty34918jj = false

func _ready():
	if(!Menu_audio.menu_audio.playing):
		Menu_audio.menu_audio.play()
	get_node("logout_warning").connect("popup_hide", self, "unfade")
	get_node("logout_warning/button_face/Button").connect("mouse_entered", self, "hover_logout_confirm", [true])
	get_node("logout_warning/button_face/Button").connect("mouse_exited", self, "hover_logout_confirm", [false])
	
	get_node("Control/username").text = head.username
	
	$instructions/exit_instructions.connect("pressed", self, "exit_instructions")
	
### TEST ###
	var player_id = head.player_ID
	if player_id == -1:
		player_id = 1
	var bot_id = head.bot_ID
	if bot_id == -1:
		bot_id = 1
############
	_bot.load_colors_from_DB(bot_id)

func _input(event):
	if event is InputEventMouse:
		_timer.start()
		if event is InputEventMouseMotion:
			var look_at = get_tree().get_root().get_mouse_position() - _bot.position
			if look_at.x > 0:
				_bot.face_right()
			else:
				_bot.face_left()
			if look_at.y > 0:
				_bot.start_walking_forward()
			else:
				_bot.start_walking_backward()

func _process(delta):
	if Input.is_key_pressed(KEY_G) and Input.is_key_pressed(KEY_E) and Input.is_key_pressed(KEY_A) and Input.is_key_pressed(KEY_R) and Input.is_key_pressed(KEY_Y):
		ty34918jj = true
	if ty34918jj:
		var look_at = get_tree().get_root().get_mouse_position() - _bot.position
		if look_at.x != 0 and look_at.y != 0:
			_bot.translate(look_at.normalized() * 3)

"""
Various nodes' signal methods
"""

func scene_change(button):
	head.play_stream(head.ui2, head.sounds.SCENE_CHANGE, head.options.WAIT)
	
	match (button):
		"ranking":
			get_tree().change_scene("res://Scenes/Screens/screen_local_scoreboard.tscn")
		"custom":
			get_tree().change_scene("res://Scenes/Screens/construction_fork.tscn")
		"credits":
			get_tree().change_scene("res://Scenes/Screens/credits.tscn")
		"train":
			Menu_audio.menu_audio.stop()
			get_tree().change_scene("res://Scenes/Load_training.tscn")
		"fight":
			Menu_audio.menu_audio.stop()
			head.load_scene("res://Scenes/battle_arena.tscn")
	pass

func button_hover_enter():
	head.play_stream(head.ui1, head.sounds.BUTTON_HOVER)

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
#	head.init_bots()
	Menu_audio.menu_audio.stop()
	get_tree().change_scene("res://Scenes/menu_title.tscn")
	pass

func _on_go_to_instructions_pressed():
	$instructions.visible = true
	$Control/title.modulate = Color("#aaaaaa")

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

func exit_instructions():
	$instructions.visible = false
	$Control/title.modulate = Color("#ffffff")
