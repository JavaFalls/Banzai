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

# JSON functions that may not be needed
# Delete if unnecessary
static func save_bots(save_bots):
	var bot_file = File.new()
	bot_file.open("res://json/bots.json", File.WRITE)
	for bot in save_bots:
		var primary = bot.items[PRIMARY]
		var secondary = bot.items[SECONDARY]
		var ability = bot.items[ABILITY]
		
		var texture = bot.texture.get_path() if bot.texture != null else ""
		var p_texture = primary.texture.get_path() if primary.texture != null else ""
		var s_texture = secondary.texture.get_path() if secondary.texture != null else ""
		var a_texture = ability.texture.get_path() if ability.texture != null else ""
		
		var data = {
			"texture": texture,
			
			"p_texture": p_texture,
			"p_text": primary.text,
			"p_stats": primary.stats,
			
			"s_texture": s_texture,
			"s_text": secondary.text,
			"s_stats": secondary.stats,
			
			"a_texture": a_texture,
			"a_text": ability.text,
			"a_stats": ability.stats
		}
		bot_file.store_line(to_json(data))
	bot_file.close()

static func load_bots():
	var load_bots = []
	var bot_file = File.new()
	var item_list = load("res://Scripts/item_list.gd")
	var bot_build = load("res://Scripts/bot_build.gd")
	
	bot_file.open("res://json/bots.json", File.READ)
	while true:
		var current_line = parse_json(bot_file.get_line())
		if bot_file.eof_reached():
			break
		var bot = bot_build.new()
		
		var primary = item_list.Item.new()
		var secondary = item_list.Item.new()
		var ability = item_list.Item.new()

		bot.texture = load(current_line["texture"])

		primary.texture = load(current_line["p_texture"])
		primary.text = current_line["p_text"]
		primary.stats = current_line["p_stats"]

		secondary.texture = load(current_line["s_texture"])
		secondary.text = current_line["s_text"]
		secondary.stats = current_line["s_stats"]

		ability.texture = load(current_line["a_texture"])
		ability.text = current_line["a_text"]
		ability.stats = current_line["a_stats"]

		bot.items.push_back(primary)
		bot.items.push_back(secondary)
		bot.items.push_back(ability)
		load_bots.push_back(bot)
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