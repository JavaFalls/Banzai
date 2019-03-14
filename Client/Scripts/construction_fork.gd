extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")
onready var head_audio = get_tree().get_root().get_node("/root/audio_stream")

onready var bot_player = $animation_bot
onready var bot_bot = $animation_bot2

const CUSTOMIZE_BOT_PATH = "res://Scenes/Screens/bot_construction.tscn"
const MAIN_MENU_PATH = "res://Scenes/main_menu.tscn"
const MOUSE_IN_COLOR = Color("#ffffff")
const MOUSE_OUT_COLOR = Color("#aaaaaa")

# Godot overrides
#------------------------------------------------
func _ready():
#### FOR TESTING #
	var player_id = head.player_ID
	if player_id == -1:
		player_id = 1
	var bot_id = head.bot_ID
	if bot_id == -1:
		bot_id = 1
##################
	bot_player.load_colors_from_DB(bot_id)
	bot_bot.load_colors_from_DB(bot_id)
	bot_player.face_right()
	bot_bot.face_left()
	
	$buttons/back/Label.modulate = MOUSE_OUT_COLOR
	$buttons/customize_bot/Label.modulate = MOUSE_OUT_COLOR
	$buttons/customize_player/Label.modulate = MOUSE_OUT_COLOR

# Signal methods
#------------------------------------------------
func _on_customize_player_pressed():
	head_audio.play_stream(head_audio.ui2, head_audio.SCENE_CHANGE, true)
	head.construction = head.PLAYER
	get_tree().change_scene(CUSTOMIZE_BOT_PATH)

func _on_customize_player_mouse_entered():
	head_audio.play_stream(head_audio.ui1, head_audio.BUTTON_HOVER)
	bot_player.start_walking_forward()
	$buttons/customize_player/Label.modulate = MOUSE_IN_COLOR

func _on_customize_player_mouse_exited():
	bot_player.stop_animation()
	$buttons/customize_player/Label.modulate = MOUSE_OUT_COLOR

func _on_customize_bot_pressed():
	head_audio.play_stream(head_audio.ui2, head_audio.SCENE_CHANGE, true)
	head.construction = head.BOT
	get_tree().change_scene(CUSTOMIZE_BOT_PATH)

func _on_customize_bot_mouse_entered():
	head_audio.play_stream(head_audio.ui1, head_audio.BUTTON_HOVER)
	bot_bot.start_walking_forward()
	$buttons/customize_bot/Label.modulate = MOUSE_IN_COLOR

func _on_customize_bot_mouse_exited():
	bot_bot.stop_animation()
	$buttons/customize_bot/Label.modulate = MOUSE_OUT_COLOR

func _on_back_pressed():
	head_audio.play_stream(head_audio.ui2, head_audio.SCENE_CHANGE, true)
	get_tree().change_scene(MAIN_MENU_PATH)

func _on_back_mouse_entered():
	head_audio.play_stream(head_audio.ui1, head_audio.BUTTON_HOVER)
	$buttons/back/Label.modulate = MOUSE_IN_COLOR

func _on_back_mouse_exited():
	$buttons/back/Label.modulate = MOUSE_OUT_COLOR
