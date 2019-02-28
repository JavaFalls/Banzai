extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

const CUSTOMIZE_BOT_PATH = "res://Scenes/Screens/bot_construction.tscn"
const MAIN_MENU_PATH = "res://Scenes/main_menu.tscn"

# Godot overrides
#------------------------------------------------
func _ready():
	pass

# Signal methods
#------------------------------------------------
func _on_customize_player_pressed():
	head.construction = head.BOT
	get_tree().change_scene(CUSTOMIZE_BOT_PATH)

func _on_customize_bot_pressed():
	head.construction = head.PLAYER
	get_tree().change_scene(CUSTOMIZE_BOT_PATH)

func _on_back_pressed():
	get_tree().change_scene(MAIN_MENU_PATH)
