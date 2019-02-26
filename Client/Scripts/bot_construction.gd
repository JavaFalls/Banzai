extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

var w = [
	{"model_id": 0, "texture": preload("res://assets/menu/test_icons/skill_b_01.png")},
	{"model_id": 1, "texture": preload("res://assets/menu/test_icons/skill_b_02.png")},
	{"model_id": 2, "texture": preload("res://assets/menu/test_icons/skill_b_03.png")},
	{"model_id": 3, "texture": preload("res://assets/menu/test_icons/skill_b_04.png")},
	{"model_id": 4, "texture": preload("res://assets/menu/test_icons/skill_b_05.png")},
	{"model_id": 5, "texture": preload("res://assets/menu/test_icons/skill_b_06.png")},
	{"model_id": 6, "texture": preload("res://assets/menu/test_icons/skill_b_07.png")}
]

# Every loaded bot is temporarily stored
var bots = []
var current = 0

var name_confirmed = false
signal name_entered

# Godot methods
#------------------------------------------------
func _ready():
#	--------------------------------------------------------------------------------------------------
	if 1 == 0:
		# FOR TESTING #
		head.player_ID = 1
		###############
		var player_bots
	#	player_bots = parse_json(head.DB.get_player_bots(head.player_ID))
		print(player_bots)
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

# Entering a name
func _on_new_button_pressed():
	$new_bot/back_panel/name_edit.text = ""
	$new_bot.visible = true
	yield(self, "name_entered")
	$new_bot.visible = false
	
### Unsure of the model id ###
	var model_id = 0
	var player_id = 1
	head.DB.new_bot(player_id, [0,0,0,0,0,0], $new_bot/back_panel/name_edit.text)
#### Get the newest bot
	#bots.append(parse_json(head.DB.get_bot(bot_ID)))
	current = bots.size()-1
	get_bot_info(bots[current])

func _on_enter_name_pressed():
	if not name_confirmed:
		var label = $new_bot/back_panel/enter_name/Label
		label.scroll("Confirm")
		yield(label, "scroll_finished")
		name_confirmed = true
	else:
		$new_bot/back_panel/enter_name/Label.text = "Enter"
		$new_bot/back_panel/enter_name/Label.modulate = Color("#ffffff")
		name_confirmed = false
		emit_signal("name_entered")

func _on_enter_name_mouse_entered():
	var tween = $new_bot/back_panel/enter_name/Label/Tween
	var label = $new_bot/back_panel/enter_name/Label
	tween.interpolate_property(label, "modulate", label.modulate, Color("#007800"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func _on_enter_name_mouse_exited():
	var tween = $new_bot/back_panel/enter_name/Label/Tween
	var label = $new_bot/back_panel/enter_name/Label
	tween.interpolate_property(label, "modulate", label.modulate, Color("#ffffff"), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func _on_test_button_pressed():
	pass

func _on_finish_button_pressed():
#	head.DB.update_bot(head.player_ID, [
#			model_id,
#			$item_scroll.current_item()["model_id"],
#			$item_scroll2.current_item()["model_id"],
#			$item_scroll3.current_item()["model_id"],
#			$color_scroll.current_color().to_rgba32(),
#			$color_scroll.current_color().to_rgba32()
#		])
	get_tree().change_scene("res://Scenes/main_menu.tscn")

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
