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

# Every loaded bot is temporarily stored
var bots = []
var current = 0

# Godot methods
#------------------------------------------------
func _ready():
#	--------------------------------------------------------------------------------------------------
	# FOR TESTING #
	head.player_ID = 1
	###############
#	var player_bots = parse_json(head.DB.get_player_bots(head.player_ID))
	print(all_bots)
	# parse all ids if returning string
	var bot_IDs = []
	var id = ""
	for c in player_bots["player_bots"]:
		if c == ",":
			bot_IDs.append(to_int(id))
			id = ""
		else:
			id += c
	for bot_ID in bot_IDs:
		bots.append(parse_json(head.DB.get_bot(bot_ID)))
#	--------------------------------------------------------------------------------------------------
	
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

# Signal methods
#------------------------------------------------
func _on_bot_left_pressed():
	if current-1 < 0:
		current = bots.size()-1
	get_bot_info(bots[current])
	
func _on_bot_right_pressed():
	if current+1 >= bots.size():
		current = 0
	get_bot_info(bots[current])
	
func _on_new_button_pressed():
	pass
	
func _on_test_button_pressed():
	pass

func _on_finish_button_pressed():
	pass

# Display/organize data
#------------------------------------------------
func grab_info(info_type):
	match info_type:
		head.PRIMARY:
			get_node("item_scroll2").emit_signal("info_reserved")
			get_node("item_scroll3").emit_signal("info_reserved")
######## display info
			get_node("item_name").text = "Powerful Weapon"
			get_node("item_description").scroll("This is the description.")
		head.SECONDARY:
			get_node("item_scroll").emit_signal("info_reserved")
			get_node("item_scroll3").emit_signal("info_reserved")
######## display info
		head.ABILITY:
			get_node("item_scroll").emit_signal("info_reserved")
			get_node("item_scroll2").emit_signal("info_reserved")
######## display info

func reset_info():
	$item_name.text = ""
	$item_description.text = ""

func get_bot_info(bot_data):
	$bot_name.text = bot_data["name"]
	$item_scroll.set_current(bot_data["primary_weapon"])
	$item_scroll2.set_current(bot_data["secondary_weapon"])
	$item_scroll3.set_current(bot_data["utility"])
	$color_scroll.set_current(null, bot_data["primary_color"])
	$color_scroll2.set_current(null, bot_data["secondary_color"])
#	$color_scroll3
#	$color_scroll4
