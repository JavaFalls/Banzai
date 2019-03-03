extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")
onready var bot_player = $animation_bot
onready var bot_bot = $animation_bot2

const CUSTOMIZE_BOT_PATH = "res://Scenes/Screens/bot_construction.tscn"
const MAIN_MENU_PATH = "res://Scenes/main_menu.tscn"

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

# Signal methods
#------------------------------------------------
func _on_customize_player_pressed():
	head.construction = head.PLAYER
	get_tree().change_scene(CUSTOMIZE_BOT_PATH)

func _on_customize_player_mouse_entered():
	bot_player.start_walking_forward()

func _on_customize_player_mouse_exited():
	bot_player.stop_animation()

func _on_customize_bot_pressed():
	head.construction = head.BOT
	get_tree().change_scene(CUSTOMIZE_BOT_PATH)

func _on_customize_bot_mouse_entered():
	bot_bot.start_walking_forward()

func _on_customize_bot_mouse_exited():
	bot_bot.stop_animation()

func _on_back_pressed():
	get_tree().change_scene(MAIN_MENU_PATH)
