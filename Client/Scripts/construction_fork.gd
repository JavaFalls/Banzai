extends Node

const CUSTOMIZE_SCREEN_PATH = "res://Scenes/Screens/bot_construction.tscn"
const MAIN_MENU_PATH = "res://Scenes/main_menu.tscn"

# Godot overrides
#------------------------------------------------
func _ready():
	pass

# Signal methods
#------------------------------------------------
func _on_customize_player_pressed():
	get_tree().change_scene(CUSTOMIZE_SCREEN_PATH)

func _on_customize_bot_pressed():
	get_tree().change_scene(CUSTOMIZE_SCREEN_PATH)

func _on_back_pressed():
	get_tree().change_scene(MAIN_MENU_PATH)
