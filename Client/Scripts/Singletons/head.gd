extends Node

# Noraml screen size
const NORMAL_HEIGHT = 900
const NORMAL_WIDTH = 1600

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
		"texture": load("res://assets/sword.png"),
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
	ai_builds = [bot_builds[BOT]]

func _input(event):
	if Input.is_action_just_pressed("shutdown"):
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
			abilities["sword1"]
		),
		BOT: load("res://Scripts/Objects/bot_build.gd").new(
			weapons["robot_face"],
			weapons["robot_face"],
			abilities["sword1"]
		)
	}
