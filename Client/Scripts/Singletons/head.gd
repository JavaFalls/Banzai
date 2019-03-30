extends Node

# The abilities used by a default robot
const DEFAULT_UTILITY = 14
const DEFAULT_PRIMARY = 2
const DEFAULT_SECONDARY = 9
const DEFAULT_PRIMARY_COLOR = Color(1, 1, 1)
const DEFAULT_SECONDARY_COLOR = Color(1, 1, 1)
const DEFAULT_ACCENT_COLOR = Color(1, 1, 1)
const DEFAULT_ANIMATION = "B1" # Should match the value found at the ANIMATION_SET_B1 constant in the bot_animation.gd file

# Weapons keys
enum {PRIMARY, SECONDARY, ABILITY}
# Bot builds keys
enum {PLAYER, BOT}
var construction = BOT

# Loading screen
var loader = preload("res://Scenes/loading.tscn")

# Screen Position and Size
var screen_size = OS.get_screen_size()
var window_size = OS.get_window_size()

# Specify which names to use from DB
var name_section = 1

# Username
var username = ""

# Player bot's ranking score change
var score_change = 0

# Did figher 1 win the battle
var battle_won = false

# Database
var player_ID = -1;
var model_ID = -1;
var player_bot_ID = -1;
var bot_ID = -1;

onready var dir = Directory.new()
onready var DB = DBConnector.new()
onready var pid = OS.shell_open(ProjectSettings.globalize_path('res://NeuralNetwork/nnserver.py'))
onready var Client = NNClient.new()

# Audio
#----------------
enum options {
	OVERRIDE, WAIT, YIELD
}

enum sounds {
	SCENE_CHANGE, BUTTON_HOVER,
	BOT_CHANGE_1, BOT_CHANGE_2, BOT_CHANGE_3,
	TEXT_SCROLL, GAME_START,
	PRIM1, PRIM2, PRIM3, PRIM4,
	SEC1, SEC2, SEC3, SEC4, SEC5, SEC6, SEC7,
	TECH1, TECH2, TECH3, TECH4, TECH5, TECH6, TECH7, TECH8, TECH9, TECH10, TECH11,
	EXP1, EXP2, EXP3, EXP4, EXP5, EXP6
}
onready var wavs = [
	preload("res://sounds/ui/sci-fi_hacking_aliens_03.wav"),
	preload("res://sounds/ui/sci-fi_beep_computer_ui_06.wav"),
	
	preload("res://sounds/ui/sci-fi_power_up_05.wav"),
	preload("res://sounds/ui/sci-fi_power_up_07.wav"),
	preload("res://sounds/ui/sci-fi_power_up_09.wav"),
	
	preload("res://sounds/ui/sci-fi_code_fail_04.wav"),
	preload("res://sounds/ui/sci-fi_driod_robot_emote_beeps_05.wav"),
	
	preload("res://sounds/weapons/primary/sci-fi_weapon_blaster_laser_boom_01.wav"),
	preload("res://sounds/weapons/primary/sci-fi_weapon_blaster_laser_boom_02.wav"),
	preload("res://sounds/weapons/primary/sci-fi_weapon_blaster_laser_boom_03.wav"),
	preload("res://sounds/weapons/primary/sci-fi_weapon_blaster_laser_boom_04.wav"),
	
	preload("res://sounds/weapons/secondary/sci-fi_weapon_blaster_laser_boom_zap_04.wav"),
	preload("res://sounds/weapons/secondary/sci-fi_weapon_blaster_laser_boom_zap_05.wav"),
	preload("res://sounds/weapons/secondary/sci-fi_weapon_blaster_laser_boom_zap_06.wav"),
	preload("res://sounds/weapons/secondary/sci-fi_weapon_blaster_laser_boom_zap_07.wav"),
	preload("res://sounds/weapons/secondary/sci-fi_weapon_blaster_laser_boom_zap_08.wav"),
	preload("res://sounds/weapons/secondary/sci-fi_weapon_blaster_laser_deep_drone_01.wav"),
	preload("res://sounds/weapons/secondary/sci-fi_weapon_blaster_laser_deep_drone_02.wav"),
	
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_01.wav"),
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_02.wav"),
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_03.wav"),
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_04.wav"),
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_05.wav"),
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_06.wav"),
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_07.wav"),
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_08.wav"),
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_09.wav"),
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_10.wav"),
	preload("res://sounds/weapons/tech/sci-fi_weapon_reload_11.wav"),
	
	preload("res://sounds/weapons/explosions/sci-fi_explosion_01.wav"),
	preload("res://sounds/weapons/explosions/sci-fi_explosion_02.wav"),
	preload("res://sounds/weapons/explosions/sci-fi_explosion_03.wav"),
	preload("res://sounds/weapons/explosions/sci-fi_explosion_04.wav"),
	preload("res://sounds/weapons/explosions/sci-fi_explosion_05.wav"),
	preload("res://sounds/weapons/explosions/sci-fi_explosion_06.wav"),
]

func play_stream(player, audio_index, option=options.OVERRIDE):
	if not player is AudioStreamPlayer:
		print("Not an audio player")
	match option:
		options.OVERRIDE:
			pass
		options.WAIT:
			if player.playing:
				yield(player, "finished")
		options.YIELD:
			if player.playing:
				return
	player.set_stream(wavs[audio_index])
	player.play()

func create_player(bus, db=0.0):
	var asp = AudioStreamPlayer.new()
	asp.set_bus(bus)
	asp.volume_db = db
	add_child(asp)
	return asp

func delete_player(player):
	yield(player, "finished")
	player.queue_free()
#----------------
# End Audio

func _ready():
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	Input.set_custom_mouse_cursor(load("res://assets/pixel_cursor.png"), Input.CURSOR_ARROW, Vector2(15, 15))
	#_test_DB()

func _input(event):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func load_scene(path):
	get_tree().change_scene_to(loader)
	yield(get_tree(), "node_added")
	get_node("/root/loading").load_scene(path)

func battle_winner_calc(fighter1_hit_points, fighter2_hit_points):
	var hit_points_diff = fighter1_hit_points - fighter2_hit_points
	if hit_points_diff > 0:
		battle_won = true
	else:
		battle_won = false
	if hit_points_diff > 250:
		score_change = 5
	elif hit_points_diff > 0:
		score_change = 3
	elif hit_points_diff == 0:
		score_change = 0
	elif hit_points_diff > -250:
		score_change = -3
	else:
		score_change = -5

#--------------------------------------------
# DB Functions
#--------------------------------------------
# Creates a new user in the database with a default bot setup.
# Expectes head.username to already be set
func create_user():
	# Due to foreign key constraints, we must create data in the DB in the following order:
	# player -> model -> bot

	# 1. Create player
	player_ID = DB.new_player(username)

	# 2. Create model and bot
	var bot_insert_arg_array = [0, 1, 2, 3, 4, 5, 6, 7]
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_MODEL_ID] = 0 # By passing 0 for the model the DBConnector will use the generic_model to create a model in the DB for the bot
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_UTILITY] = DEFAULT_UTILITY
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_SECONDARY_WEAPON] = DEFAULT_SECONDARY
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_PRIMARY_WEAPON] = DEFAULT_PRIMARY
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_PRIMARY_COLOR] = DEFAULT_PRIMARY_COLOR.to_rgba32()
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_SECONDARY_COLOR] = DEFAULT_SECONDARY_COLOR.to_rgba32()
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_ACCENT_COLOR] = DEFAULT_ACCENT_COLOR.to_rgba32()
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_ANIMATION] = DEFAULT_ANIMATION
	bot_ID = DB.new_bot(player_ID, bot_insert_arg_array, username)
	player_bot_ID = DB.new_bot(player_ID, bot_insert_arg_array, username)
	model_ID = bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_MODEL_ID] # Since arrays are pass by reference, new_bot() is able to use the array like an OUT parameter to return the model_ID
	
	# Save Bot after training
func save_bot():
	var message = '{ "Message Type": "Save", "File Name": "File_%s.h5"}' % str(bot_ID)
	Client.send_request(message)
	var output = Client.get_response()
	DB.update_model_by_bot_id(bot_ID, 'File_%s.h5' % str(bot_ID))
	dir.remove(ProjectSettings.globalize_path('res://NeuralNetwork/models/File_%s.h5' % str(bot_ID)))