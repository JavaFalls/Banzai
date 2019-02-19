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

# Godot methods
#------------------------------------------------
func _ready():
	var is1 = get_node("item_scroll")
	var is2 = get_node("item_scroll2")
	var is3 = get_node("item_scroll3")
	
	is1.set_data_points(10, 16)
	is1.set_items(w)
	is2.set_data_points(10, 16)
	is2.set_items(w)
	is3.set_data_points(10, 16)
	is3.set_items(w)
	
	is1.connect("info_queried", self, "grab_info", [head.PRIMARY])
	is2.connect("info_queried", self, "grab_info", [head.SECONDARY])
	is3.connect("info_queried", self, "grab_info", [head.ABILITY])

# Loading
#------------------------------------------------
func load_bot_data(data):
	bot.name = data.name
	bot.primary = data.primary
	bot.secondary = data.secondary
	bot.utility = data.utility
	bot.primary_color = data.primary_color
	bot.secondary_color = data.secondary_color

# Info retrieval and logic
#------------------------------------------------
func grab_info(info_type):
	match info_type:
		head.PRIMARY:
			get_node("item_scroll2").emit_signal("info_reserved")
			get_node("item_scroll3").emit_signal("info_reserved")
######## display info
			get_node("TEST/Animation").play("print")
#			get_node("Label4").text
		head.SECONDARY:
			get_node("item_scroll").emit_signal("info_reserved")
			get_node("item_scroll3").emit_signal("info_reserved")
######## display info
			get_node("TEST/Animation").play("print")
			pass
		head.ABILITY:
			get_node("item_scroll").emit_signal("info_reserved")
			get_node("item_scroll2").emit_signal("info_reserved")
######## display info
			get_node("TEST/Animation").play("print")
			pass
