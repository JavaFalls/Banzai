extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

onready var _background = get_node("Control/MarginContainer/background")
onready var _timer = get_node("timeout")
onready var _tween = get_node("Tween")
onready var _bot = $animation_bot

var ty34918jj = false
var prevent_messengers_to_zorro = { # Track if messenger is dead. If so, keep sending messengers.
	'messenger_ferdinand': true,
	'messenger_dutch': true,
	'messenger_gibson': true,
	'messenger_Stan_Lee': true,
	'messenger_carl': true
}
func reincarnate():
	for dude in prevent_messengers_to_zorro:
		prevent_messengers_to_zorro[dude] = true
var HELP = "well?"
var phase1 = "world in peril"
var phase2 = "hope in the air"
var phase3 = "zorro hears the whispers"
var phase4 = "swing into action"
var phase4point5 = "horse runs into a wall"

func _ready():
	if(!Menu_audio.menu_audio.playing):
		Menu_audio.menu_audio.play()
	get_node("logout_warning").connect("popup_hide", self, "unfade")
	get_node("logout_warning/button_face/Button").connect("mouse_entered", self, "hover_logout_confirm", [true])
	get_node("logout_warning/button_face/Button").connect("mouse_exited", self, "hover_logout_confirm", [false])
	
	get_node("Control/username").text = head.username
	
	$instructions/exit_instructions.connect("pressed", self, "exit_instructions")

	_bot.load_colors_from_DB(head.bot_ID)

func _input(event):
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
	if event is InputEventKey:
		if event.scancode == KEY_G:
			prevent_messengers_to_zorro["messenger_ferdinand"] = false
			HELP = phase1
			print(HELP)
		elif event.scancode == KEY_E and not prevent_messengers_to_zorro["messenger_ferdinand"]:
			prevent_messengers_to_zorro["messenger_dutch"] = false
			HELP = phase2
			print(HELP)
		elif event.scancode == KEY_A and not prevent_messengers_to_zorro["messenger_dutch"]:
			prevent_messengers_to_zorro["messenger_gibson"] = false
			HELP = phase3
			print(HELP)
		elif event.scancode == KEY_R and not prevent_messengers_to_zorro["messenger_gibson"]:
			prevent_messengers_to_zorro["messenger_Stan_Lee"] = false
			HELP = phase4
			print(HELP)
		elif event.scancode == KEY_Y and not prevent_messengers_to_zorro["messenger_Stan_Lee"]:
			prevent_messengers_to_zorro["messenger_carl"] = false
			HELP = phase4point5
			print(HELP) # I keep printing help
			ty34918jj = true
		elif event.scancode == KEY_ENTER and not prevent_messengers_to_zorro["messenger_carl"]:
			zorro_is_coming()
		else:
			HELP = "not today..."
			reincarnate()

func _process(delta):
	if ty34918jj:
		var look_at = get_tree().get_root().get_mouse_position() - _bot.position
		if look_at.x != 0 and look_at.y != 0:
			_bot.translate(look_at.normalized() * 3)
	
	var time = OS.get_time()
	$time.text = "%02d:%02d:%02d" % [time["hour"]%12, time["minute"], time["second"]]

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
	get_node("logout_warning").hide()
func zorro_is_coming():
	weapon_creator.get_weapon_stats(weapon_creator.W_PRI_ZORROS_GLARE)["implemented"] = true
	weapon_creator.get_weapon_stats(weapon_creator.W_SEC_ZORROS_WIT)["implemented"] = true
	weapon_creator.get_weapon_stats(weapon_creator.W_ABI_ZORROS_HONOR)["implemented"] = true
	_bot.set_bot_type(_bot.ANIMATION_SET_B1_ZORRO)
	head.DB.update_bot(head.bot_ID,
	                   [
					    head.DB.NULL_INT, # UPDATE_BOT_ARGS_PLAYER_ID
						head.DB.NULL_INT, # UPDATE_BOT_ARGS_MODEL_ID
						head.DB.NULL_INT, # UPDATE_BOT_ARGS_RANKING
						head.DB.NULL_INT, # UPDATE_BOT_ARGS_PRIMARY_WEAPON
						head.DB.NULL_INT, # UPDATE_BOT_ARGS_SECONDARY_WEAPON
						head.DB.NULL_INT, # UPDATE_BOT_ARGS_UTILITY
						head.DB.NULL_COLOR, # UPDATE_BOT_ARGS_PRIMARY_COLOR
						head.DB.NULL_COLOR, # UPDATE_BOT_ARGS_SECONDARY_COLOR
						head.DB.NULL_COLOR, # UPDATE_BOT_ARGS_ACCENT_COLOR
						_bot.ANIMATION_SET_B1_ZORRO # UPDATE_BOT_ARGS_ANIMATION
					   ],
					   "")

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
	Menu_audio.menu_audio.stop()
	weapon_creator.get_weapon_stats(weapon_creator.W_PRI_ZORROS_GLARE)["implemented"] = false
	weapon_creator.get_weapon_stats(weapon_creator.W_SEC_ZORROS_WIT)["implemented"] = false
	weapon_creator.get_weapon_stats(weapon_creator.W_ABI_ZORROS_HONOR)["implemented"] = false
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
