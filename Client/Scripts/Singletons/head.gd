extends Node

# Noraml screen size
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

# DB Related constants
const FILEPATH_GENERIC_BOT_MODEL = "res://NeuralNetwork/generic_model.h5" # where we store the generic_model used to create brand new default robots
const FILEPATH_STORE_BOT_MODEL = "res://NeuralNetwork/my_model.h5" # where the DBConnector will go to look up an ai_model to store in the DB
const FILEPATH_LOAD_BOT_MODEL = "res://NeuralNetwork/my_model_new.h5" # where an ai_model just loaded from the DB is stored

# The abilities used by a default robot
const DEFAULT_UTILITY = 0
const DEFAULT_PRIMARY = 0
const DEFAULT_SECONDARY = 0

# Weapons keys
enum {PRIMARY, SECONDARY, ABILITY}
# Bot builds keys
enum {PLAYER BOT}

# Loading screen
var loader = preload("res://Scenes/loading.tscn")

# Screen Position and Size
var screen_size = OS.get_screen_size()
var window_size = OS.get_window_size()

# Username
var username = ""

# Player bot's ranking score change
var score_change = 0

# Did figher 1 win the battle
var battle_won = false

# Database
var player_ID = null;
var model_ID = null;
var bot_ID = null;
onready var DB = DBConnector.new()

# Weapons/abilities
onready var weapons = {
	"robot_face": {
		"scene": null,
		"texture": load("res://assets/icon.png"),
		"name": "Robot Face",
		"attack": 1,
		"armor": 2,
		"range": 3,
		"points": 4,
		"weight": 5
	},
	"sword": {
		"scene": null,
		"texture": load("res://assets/sword.png"),
		"name": "Sword",
		"attack": 2,
		"armor": 4,
		"range": 3,
		"points": 6,
		"weight": 15
	},
	"red_block": {
		"scene": null,
		"texture": load("res://assets/wall.png"),
		"name": "Nothing Particular",
		"attack": 0,
		"armor": 20,
		"range": 2,
		"points": 8,
		"weight": 1
	}
}

onready var abilities = {
	"sword1": {
		"scene": null,
		"texture": load("res://assets/bots/front.png"),
		"name": "Sword1",
		"attack": 0,
		"armor": 0,
		"range": 2,
		"points": 0,
		"weight": 1
	},
	"sword2": {
		"scene": null,
		"texture": load("res://assets/sword.png"),
		"name": "Sword2",
		"attack": 0,
		"armor": 0,
		"range": 0,
		"points": 0,
		"weight": 0
	},
	"sword3": {
		"scene": null,
		"texture": load("res://assets/sword.png"),
		"name": "Sword3",
		"attack": 0,
		"armor": 1,
		"range": 1,
		"points": 0,
		"weight": 1
	}
}

onready var primary_list = load("res://Scripts/Objects/item_list.gd").new(weapons.values())
onready var secondary_list = load("res://Scripts/Objects/item_list.gd").new(weapons.values())
onready var ability_list = load("res://Scripts/Objects/item_list.gd").new(abilities.values())

# Bots
var bot_builds
var ai_builds

func _ready():
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	init_bots()
	_test_DB()
	ai_builds = [bot_builds[BOT]]

func _input(event):
	if Input.is_action_just_pressed("shutdown"):
		if (DB.is_connection_open()):
			DB.close_connection()
		get_tree().quit()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func load_scene(path):
	get_tree().change_scene_to(loader)
	yield(get_tree(), "node_added")
	get_node("/root/loading").load_scene(path)

func find_bot(bot):
	for i in range(ai_builds.size()):
		if ai_builds[i].compare(bot):
			return ai_builds[i]
	return null

func save_bot(new_bot):
	ai_builds.push_back(new_bot)

func init_bots():
	bot_builds = {
		PLAYER: load("res://Scripts/Objects/bot_build.gd").new(
			weapons["robot_face"],
			weapons["robot_face"],
			abilities["sword1"],
			load("res://assets/bots/front.png")
		),
		BOT: load("res://Scripts/Objects/bot_build.gd").new(
			weapons["robot_face"],
			weapons["robot_face"],
			abilities["sword1"],
			load("res://assets/bots/front.png")
		)
	}

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
	
	# 2. Create model
	# - Load generic model
	var data
	var file_generic_model = File.new()
	var file_store_model = File.new()
	file_generic_model.open(FILEPATH_GENERIC_BOT_MODEL, File.READ)
	file_store_model.open(FILEPATH_STORE_BOT_MODEL, File.WRITE)
	while(true):
		data = file_generic_model.get_8()
		if(file_generic_model.eof_reached()):
			break;
		else:
			file_store_model.store_8(data)
	#while(!file_generic_model.eof_reached()):
	#	file_store_model.store_8(file_generic_model.get_8()) # This is somehow modifing the file........ its should be create an identical copy but it is not
	file_generic_model.close()
	file_store_model.close()
	
	# - Store model
	model_ID = DB.new_model(player_ID)
	
	# 3. Create bot
	var bot_insert_arg_array = [0, 0, 0, 0]
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_MODEL_ID] = model_ID
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_UTILITY] = DEFAULT_UTILITY
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_SECONDARY_WEAPON] = DEFAULT_SECONDARY
	bot_insert_arg_array[DBConnector.NEW_BOT_ARGS_PRIMARY_WEAPON] = DEFAULT_PRIMARY
	bot_ID = DB.new_bot(player_ID, bot_insert_arg_array, "v1")



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
	var botInsArgArray = [0, 1, 2, 3]
	bot_ID = DB.new_bot(player_ID, botInsArgArray, "mech9000")
	print("bot_ID: ", bot_ID)
	model_ID = botInsArgArray[0]
	print("model_ID: ", model_ID)
	print("DB.get_bot: ", DB.get_bot(bot_ID, true))
	var botUpdArgArray = [player_ID, model_ID, 1000, 3, 0, 1]
	print("DB.update_bot: ", DB.update_bot(bot_ID, botUpdArgArray, "mech9001", true))
	print("Model funcs:==============================")
	model_ID = DB.new_model(player_ID)
	print("Model_ID: ", model_ID)
	print("DB.get_model(): ", DB.get_model(model_ID))
	print("DB.get_model_by_bot_id(): ", DB.get_model_by_bot_id(bot_ID))
	print("DB.update_model(): ", DB.update_model(model_ID))
	print("DB.update_model_by_bot_id(): ", DB.update_model_by_bot_id(bot_ID))
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