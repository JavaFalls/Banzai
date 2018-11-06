extends Node

# Noraml screen size
const NORMAL_HEIGHT = 900
const NORMAL_WIDTH = 1600

# Weapons keys
enum {PRIMARY, SECONDARY, ABILITY}
# Bot keys
enum {PLAYER, BOT}

# Screen Position and Size
var screen_size = OS.get_screen_size()
var window_size = OS.get_window_size()

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
var bots = []
func init_bots():
	var bot_build = load("res://Scripts/bot_build.gd")
	bots = [
		bot_build.new([
			primaries.items[0],
			secondaries.items[0],
			abilities.items[0]
		]),
		bot_build.new([
			primaries.items[0],
			secondaries.items[0],
			abilities.items[0]
		])
	]

static func save_bots(save_bots):
	var bot_file = File.new()
	bot_file.open("res://json/bot.json", File.WRITE)
	for bot in save_bots:
		var d = {
			"texture": bot.texture,
			"primary": bot.items[PRIMARY],
			"secondary": bot.items[SECONDARY],
			"ability": bot.items[ABILITY]
		}
		bot_file.store_line(to_json(d))
	bot_file.close()

static func load_bots():
	var load_bots = []
	var bot_file = File.new()
	var bot_build = load("res://Scripts/bot_build.gd")
	
	bot_file.open("res://json/bot.json", File.READ)
	while true:
		var current_line = parse_json(bot_file.get_line())
		if bot_file.eof_reached():
			break
		var bot = bot_build.new(null)
		bot.texture = current_line["texture"]
		bot.items[PRIMARY] = load(current_line["primary"]).instance()
		bot.items[SECONDARY] = load(current_line["secondary"]).instance()
		bot.items[ABILITY] = load(current_line["ability"]).instance()
		load_bots.push_back(bot)
		
#		bot = load("res://Scripts/bot_build.gd").new([
#			load("res://Scripts/item_list.gd").Item.new(
#				load("res://assets/icon.png"),
#				"Robot Face",
#				{
#					"attack": 1,
#					"armor": 2,
#					"range": 3,
#					"points": 4,
#					"weight": 5
#				}
#			)
#		])
	bot_file.close()
	return load_bots

static func load_weapons():
	
	return

func _ready():
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	init_bots()

func _input(event):
	if Input.is_action_just_pressed("shutdown"):
		get_tree().quit()
	if Input.is_action_just_pressed("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen