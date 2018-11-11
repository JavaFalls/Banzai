extends Node

# Noraml screen size
const NORMAL_HEIGHT = 900
const NORMAL_WIDTH = 1600

# Weapons keys
enum {PRIMARY, SECONDARY, ABILITY}
# Bot builds keys
enum {PLAYER BOT}

# Screen Position and Size
var screen_size = OS.get_screen_size()
var window_size = OS.get_window_size()

# Username
var username = ""

# Weapons/abilities
onready var item_list = load("res://Scripts/item_list.gd")
onready var primaries = item_list.new([
	item_list.Item.new(load("res://assets/icon.png"), "Robot Face", {
		"attack": 1,
		"armor": 2,
		"range": 3,
		"points": 4,
		"weight": 5
	}),
	item_list.Item.new(load("res://assets/sword.png"), "Sword", {
		"attack": 2,
		"armor": 4,
		"range": 3,
		"points": 6,
		"weight": 15
	}),
	item_list.Item.new(load("res://assets/wall.png"), "Nothing Particular", {
		"attack": 0,
		"armor": 20,
		"range": 2,
		"points": 8,
		"weight": 1
	})
])

onready var secondaries = item_list.new([
	item_list.Item.new(load("res://assets/sword.png"), "Sword1", {
		"attack": 0,
		"armor": 0,
		"range": 0,
		"points": 0,
		"weight": 0
	}),
	item_list.Item.new(load("res://assets/sword.png"), "Sword2", {
		"attack": 1,
		"armor": 2,
		"range": 32,
		"points": 8,
		"weight": 3
	}),
	item_list.Item.new(load("res://assets/sword.png"), "Sword3", {
		"attack": 2,
		"armor": 3,
		"range": 6,
		"points": 2,
		"weight": 4
	})
])

onready var abilities = item_list.new([
	item_list.Item.new(load("res://assets/sword.png"), "Sword1", {
		"attack": 0,
		"armor": 0,
		"range": 2,
		"points": 0,
		"weight": 1
	}),
	item_list.Item.new(load("res://assets/sword.png"), "Sword2", {
		"attack": 0,
		"armor": 0,
		"range": 0,
		"points": 0,
		"weight": 0
	}),
	item_list.Item.new(load("res://assets/sword.png"), "Sword3", {
		"attack": 0,
		"armor": 1,
		"range": 1,
		"points": 0,
		"weight": 1
	})
])

# Bots
onready var bot_builds = {
	PLAYER: {
		PRIMARY: primaries.items[0],
		SECONDARY: secondaries.items[0],
		ABILITY: abilities.items[0]
	},
	BOT: {
		PRIMARY: primaries.items[0],
		SECONDARY: secondaries.items[0],
		ABILITY: abilities.items[0]
	}
}

#onready var bot_builds = [
#	load("res://Scripts/bot_build.gd").new([
#		primaries.items[0],
#		secondaries.items[0],
#		abilities.items[0]
#	]),
#	load("res://Scripts/bot_build.gd").new([
#		primaries.items[0],
#		secondaries.items[0],
#		abilities.items[0]
#	])
#]
var ai_builds = []

func is_ai_bot(bot):
	for i in range(PLAYER+1, ai_builds.size()):
		if (ai_builds[i].items[PRIMARY] == bot.items[PRIMARY] and
			 ai_builds[i].items[SECONDARY] == bot.items[SECONDARY] and
			 ai_builds[i].items[ABILITY] == bot.items[ABILITY] and
			 ai_builds[i].texture == bot.texture):
			return true
	return false

func save_bot(new_bot):
	ai_builds.push_back(new_bot)

func _ready():
	OS.set_window_position(screen_size*0.5 - window_size*0.5)

func _input(event):
	if Input.is_action_just_pressed("shutdown"):
		get_tree().quit()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen