extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

onready var bot_player = $animation_bot
onready var bot_bot = $animation_bot2

const CUSTOMIZE_BOT_PATH = "res://Scenes/Screens/bot_construction.tscn"
const MAIN_MENU_PATH = "res://Scenes/main_menu.tscn"
const MOUSE_IN_COLOR = Color("#ffffff")
const MOUSE_OUT_COLOR = Color("#aaaaaa")

# Godot overrides
#------------------------------------------------
func _ready():
	bot_player.load_colors_from_DB(head.player_bot_ID)
	bot_bot.load_colors_from_DB(head.bot_ID)
	bot_player.face_right()
	bot_bot.face_left()
	
	$buttons/back/Label.modulate = MOUSE_OUT_COLOR
	$buttons/customize_bot/Label.modulate = MOUSE_OUT_COLOR
	$buttons/customize_player/Label.modulate = MOUSE_OUT_COLOR

# Signal methods
#------------------------------------------------
func _on_customize_player_pressed():
	var sound = head.create_player("UI")
	head.play_stream(sound, head.sounds.SCENE_CHANGE)
	head.delete_player(sound)
	head.construction = head.PLAYER
	head.name_section = 1 # Use player names
	get_tree().change_scene(CUSTOMIZE_BOT_PATH)

func _on_customize_player_mouse_entered():
	var sound = head.create_player("UI")
	head.play_stream(sound, head.sounds.BUTTON_HOVER)
	head.delete_player(sound)
	bot_player.start_walking_forward()
	$buttons/customize_player/Label.modulate = MOUSE_IN_COLOR

func _on_customize_player_mouse_exited():
	bot_player.stop_animation()
	$buttons/customize_player/Label.modulate = MOUSE_OUT_COLOR

func _on_customize_bot_pressed():
	var sound = head.create_player("UI")
	head.play_stream(sound, head.sounds.SCENE_CHANGE)
	head.delete_player(sound)
	head.construction = head.BOT
	head.name_section = 1 # Use bot names
	get_tree().change_scene(CUSTOMIZE_BOT_PATH)

func _on_customize_bot_mouse_entered():
	var sound = head.create_player("UI")
	head.play_stream(sound, head.sounds.BUTTON_HOVER)
	head.delete_player(sound)
	bot_bot.start_walking_forward()
	$buttons/customize_bot/Label.modulate = MOUSE_IN_COLOR

func _on_customize_bot_mouse_exited():
	bot_bot.stop_animation()
	$buttons/customize_bot/Label.modulate = MOUSE_OUT_COLOR

func _on_back_pressed():
	var sound = head.create_player("UI")
	head.play_stream(sound, head.sounds.SCENE_CHANGE)
	head.delete_player(sound)
	get_tree().change_scene(MAIN_MENU_PATH)

func _on_back_mouse_entered():
	var sound = head.create_player("UI")
	head.play_stream(sound, head.sounds.BUTTON_HOVER)
	head.delete_player(sound)
	$buttons/back/Label.modulate = MOUSE_IN_COLOR

func _on_back_mouse_exited():
	$buttons/back/Label.modulate = MOUSE_OUT_COLOR
