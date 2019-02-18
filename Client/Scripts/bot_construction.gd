extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

var w = [
	{"texture": preload("res://assets/menu/test_icons/skill_b_01.png")},
	{"texture": preload("res://assets/menu/test_icons/skill_b_02.png")},
	{"texture": preload("res://assets/menu/test_icons/skill_b_03.png")},
	{"texture": preload("res://assets/menu/test_icons/skill_b_04.png")},
	{"texture": preload("res://assets/menu/test_icons/skill_b_05.png")},
	{"texture": preload("res://assets/menu/test_icons/skill_b_06.png")},
	{"texture": preload("res://assets/menu/test_icons/skill_b_07.png")}
]

# Bots
var player = {
	"name": "",
	"primary": 0,
	"secondary": 0,
	"utility": 0,
	"primary_color": 0,
	"secondary_color": 0
}
var bot = {
	"name": "",
	"primary": 0,
	"secondary": 0,
	"utility": 0,
	"primary_color": 0,
	"secondary_color": 0
}

# Stats
var stats = [
	"Attack: %3d"
]

func _ready():
	get_node("item_scroll").set_data_points(10, 16)
	get_node("item_scroll").set_items(w)

# Loading
#------------------------------------------------
func load_bot_data(data):
	bot.name = data.name
	bot.primary = data.primary
	bot.secondary = data.secondary
	bot.utility = data.utility
	bot.primary_color = data.primary_color
	bot.secondary_color = data.secondary_color
