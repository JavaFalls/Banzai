extends Node

# Noraml screen size
const NORMAL_HEIGHT = 900
const NORMAL_WIDTH = 1600

# Weapons keys
enum {PRIMARY, SECONDARY, ABILITY}
# Bot keys
enum {PLAYER, BOT}

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

#static 
func save_bots(save_bots):
	var bot_file = File.new()
	bot_file.open("res://json/bot.json", File.WRITE)
	for bot in save_bots:
		var primary = bot.items[PRIMARY]
		var secondary = bot.items[SECONDARY]
		var ability = bot.items[ABILITY]
		var d = {
			"texture": bot.texture,
			"primary": {
				"texture": primary.texture,
				"text": primary.text,
				"stats": primary.stats
			},
			"secondary": bot.items[SECONDARY],
			"ability": bot.items[ABILITY]
		}
		bot_file.store_line(to_json(d))
	bot_file.close()
	var it = primaries.items[0]
	print(it)

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
#		bot.items[PRIMARY] = current_line["primary"]
		bot.items[SECONDARY] = current_line["secondary"]
		bot.items[ABILITY] = current_line["ability"]
		load_bots.push_back(bot)
	
	bot_file.close()
	return load_bots

static func load_weapons():
	
	return

func _ready():
	init_bots()
