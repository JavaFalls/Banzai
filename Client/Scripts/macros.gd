extends Node

# Noraml screen size
const NORMAL_HEIGHT = 900
const NORMAL_WIDTH = 1600

# Bot keys
enum {PLAYER, BOT}
# Weapons keys
enum {PRIMARY, SECONDARY, ABILITY}

# Bots
var bots = {
	PLAYER: null,
	BOT: null
}

func save_bots(bots):
	var bot_file = File.new()
	bot_file.open("res://json/bot.json", File.WRITE)
	for bot in bots:
		var d = {
			"texture": bot.texture,
			"primary": bot.items[PRIMARY],
			"secondary": bot.items[SECONDARY],
			"ability": bot.items[ABILITY]
		}
		bot_file.store_line(to_json(d))
	bot_file.close()
	print("done")

func load_bots():
	var bots = []
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
		bots.push_back(bot)
		
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
	return bots

static func load_weapons():
	
	return