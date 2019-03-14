extends Node

# Normal screen size
const NORMAL_HEIGHT = 900
const NORMAL_WIDTH = 1600

const resolutions = [
	400,
	512,
	640,
	800,
	1024,
	NORMAL_WIDTH
]

# The abilities used by a default robot
const DEFAULT_UTILITY = 14
const DEFAULT_PRIMARY = 2
const DEFAULT_SECONDARY = 9
const DEFAULT_PRIMARY_COLOR = Color(1, 1, 1)
const DEFAULT_SECONDARY_COLOR = Color(1, 1, 1)
const DEFAULT_ACCENT_COLOR = Color(1, 1, 1)
const DEFAULT_LIGHT_COLOR = Color(1, 1, 1)

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
var pid = OS.shell_open(ProjectSettings.globalize_path('res://NeuralNetwork/nnserver.py'))

# Username
var username = ""

# Player bot's ranking score change
var score_change = 0

# Did figher 1 win the battle
var battle_won = false

# Database
var player_ID = -1;
var model_ID = -1;
var bot_ID = -1;
onready var DB = DBConnector.new()
onready var Client = NNClient.new()

# Bot Info
var bot = {
	"bot_ID"    : 0000,
	"name"      : "",
	"player_ID" : 0000,
	"ranking"   : 0000,
	"primary"   : 0001,
	"secondary" : 0002,
	"utility"   : 0003
}

# Weapons/abilities
enum WPN {ROBOT_FACE, SWORD, RED_BLOCK}
enum ABL {SWORD1, SWORD2, SWORD3}

onready var weapons = [
	{ # Robot face
		"scene": null,
		"texture": load("res://assets/icon.png"),
		"name": "Robot Face",
		"stats": 0
	},
	{ # Sword
		"scene": null,
		"texture": load("res://assets/sword.png"),
		"name": "Sword",
		"stats": 0
	},
	{ # Red block
		"scene": null,
		"texture": load("res://assets/wall.png"),
		"name": "Nothing Particular",
		"stats": 0
	}
]

onready var abilities = [
	{ # Sword 1
		"scene": null,
		"texture": load("res://assets/bots/front.png"),
		"name": "Sword1",
		"stats": 0
	},
	{ # Sword 2
		"scene": null,
		"texture": load("res://assets/sword.png"),
		"name": "Sword2",
		"stats": 0
	},
	{ # Sword 3
		"scene": null,
		"texture": load("res://assets/sword.png"),
		"name": "Sword3",
		"stats": 0
	}
]

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
	if hit_points_diff > 5:
		score_change = 5
	elif hit_points_diff > 0:
		score_change = 3
	elif hit_points_diff == 0:
		score_change = 0
	elif hit_points_diff > -5:
		score_change = -3
	else:
		score_change = -5

#########################################
# This may be useless
#func load_new_script(object, script_path):
#	if typeof(object) == TYPE_OBJECT and typeof(script_path) == TYPE_STRING:
#		var script = load(script_path)
#		object.set_script(script)
#		script.reload()

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
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_LIGHT_COLOR] = DEFAULT_LIGHT_COLOR.to_rgba32()
	bot_ID = DB.new_bot(player_ID, bot_insert_arg_array, "v1")
	model_ID = bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_MODEL_ID] # Since arrays are pass by reference, new_bot() is able to use the array like an OUT parameter to return the model_ID



func _test_DB():
	# Test the DB functions
	print("DB Testing begin")
	print("==========================================")
	print("Player funcs:=============================")
	player_ID = DB.new_player("SuperPlayer9000")
	print("player_ID: ", player_ID)
	print("DB.get_player(): ", DB.get_player(player_ID))
	print("DB.update_player(): ", DB.update_player(player_ID, "NewName2000"))
	print("Bot funcs:================================")
	var botInsArgArray = [0, 1, 2, 3, Color(1, 1, 1, 1).to_rgba32(), Color(1, 1, 1, 1).to_rgba32(), Color(0, 0, 0, 1).to_rgba32(), Color(1, 0, 0, 1).to_rgba32()]
	bot_ID = DB.new_bot(player_ID, botInsArgArray, "mech9000")
	print("bot_ID: ", bot_ID)
	model_ID = botInsArgArray[0]
	print("model_ID: ", model_ID)
	print("DB.get_bot: ", DB.get_bot(bot_ID))
	var botUpdArgArray = [player_ID, model_ID, 1000, 3, 0, 1, Color(0, 0, 0, 1).to_rgba32(), Color(1, 1, .5, 1).to_rgba32(), 0, Color(0.5, 0.5, 1, 1).to_rgba32()]
	print("DB.update_bot: ", DB.update_bot(bot_ID, botUpdArgArray, "mech9001"))
	print("Model funcs:==============================")
	model_ID = DB.new_model(player_ID, "generic_model.h5")
	print("Model_ID: ", model_ID)
	print("DB.get_model(): ", DB.get_model(model_ID, "get_model.h5"))
	print("DB.get_model_by_bot_id(): ", DB.get_model_by_bot_id(bot_ID, "get_model.h5"))
	print("DB.update_model(): ", DB.update_model(model_ID, "get_model.h5"))
	print("DB.update_model_by_bot_id(): ", DB.update_model_by_bot_id(bot_ID, "get_model.h5"))
	print("Score funcs:==============================")
	print("DB.get_name_parts(1): ", DB.get_name_parts(1));
	print("DB.get_bot_range(): ", DB.get_bot_range(bot_ID, 0, 500));
	print("DB.get_max_score(): ", DB.get_max_score());
	print("DB.get_min_score(): ", DB.get_min_score());
	print("Connection funcs:=========================")
	print("DB.is_connection_open(): ", DB.is_connection_open())
	print("DB.close_connection(): ", DB.close_connection())
	print("DB.is_connection_open(): ", DB.is_connection_open())
	print("DB.open_connection(): ", DB.open_connection())
	print("DB.is_connection_open(): ", DB.is_connection_open())
	print("DB.close_connection(): ", DB.close_connection())
	print("DB.is_connection_open(): ", DB.is_connection_open())
	print("==========================================")
