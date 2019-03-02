extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

onready var constructing_player = (head.construction == head.PLAYER)
onready var name_choice_scene = preload("res://Scenes/name_choice.tscn")

### TEST ITEMS ###
var w = [
	{"id": 0, "name": "Powerful Weapon", "description": "This is the description", "texture": preload("res://assets/menu/test_icons/skill_b_01.png")},
	{"id": 1, "name": "Powerful Weapon", "description": "This is the description", "texture": preload("res://assets/menu/test_icons/skill_b_02.png")},
	{"id": 2, "name": "Powerful Weapon", "description": "This is the description", "texture": preload("res://assets/menu/test_icons/skill_b_03.png")},
	{"id": 3, "name": "Powerful Weapon", "description": "This is the description", "texture": preload("res://assets/menu/test_icons/skill_b_04.png")},
	{"id": 4, "name": "Powerful Weapon", "description": "This is the description", "texture": preload("res://assets/menu/test_icons/skill_b_05.png")},
	{"id": 5, "name": "Powerful Weapon", "description": "This is the description", "texture": preload("res://assets/menu/test_icons/skill_b_06.png")},
	{"id": 6, "name": "Powerful Weapon", "description": "This is the description", "texture": preload("res://assets/menu/test_icons/skill_b_07.png")}
]

# Every loaded bot is temporarily stored
var bots = [] # Both the id and its bot will have the same index
var bot_ids = []
var current = 0

### unneeded variable and signal soon ###
var name_confirmed = false
signal name_entered

# Godot methods
#------------------------------------------------
func _ready():
#	if head.construction == head.PLAYER:
#		head.load_new_script(self, "res://Scripts/player_construction.gd")
	
	if constructing_player:
		$bot_left.visible = false
		$bot_right.visible = false
		$new_button.visible = false
	
#### FOR TESTING #
	var player_id = head.player_ID
	if player_id == -1:
		player_id = 1
	var bot_id = 1
##################	
	var player_bots = parse_json(head.DB.get_player_bots(player_id))
	var id = ""
	for c in player_bots["data"][0]["player_bots"]:
		if c == ",":
			if id != "":
				# Get player bot or all other bots
				if not constructing_player:
					bots.append(parse_json(head.DB.get_bot(id.to_int()))["data"][0])
					bot_ids.append(id.to_int())
				elif constructing_player and id.to_int() == bot_id:
					bots.append(parse_json(head.DB.get_bot(id.to_int()))["data"][0])
					bot_ids.append(id.to_int())
					break
				id = ""
		else:
			id += c
	
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
	
	if not bots.empty():
		get_bot_info(bots[0])

# Signal methods
#------------------------------------------------
func _on_bot_left_pressed():
	update_current_bot()
	current = bots.size()-1 if current-1 < 0 else current-1
	get_bot_info(bots[current])
	
func _on_bot_right_pressed():
	update_current_bot()
	current = 0 if current+1 >= bots.size() else current+1
	get_bot_info(bots[current])

# Entering a name
func _on_new_button_pressed():
	var new_name = ""
	if name_choice_scene.can_instance():
		$backlight/Light2D.enabled = false
		var name_choice_node = name_choice_scene.instance(PackedScene.GEN_EDIT_STATE_DISABLED)
		add_child(name_choice_node)
		yield(name_choice_node, "name_entered")
		new_name = name_choice_node.get_username()
		name_choice_node.queue_free()
		$backlight/Light2D.enabled = true
	
#### FOR TESTING #
	var player_id = head.player_ID
	if player_id == -1:
		player_id = 1
##################
	if not head.DB.new_bot(player_id, [0,0,0,0,0,0,0,0], new_name):
		print("Creating a new bot failed")
	else:
		# Get the newest bot
		var player_bots = parse_json(head.DB.get_player_bots(player_id))
		var id = ""
		for c in player_bots["data"][0]["player_bots"]:
			if c == ",":
				var int_id = id.to_int()
				var present = false
				for bot_id in bot_ids:
					if int_id == bot_id:
						present = true
						break
				if not present:
					bots.append(parse_json(head.DB.get_bot(int_id))["data"][0])
					bot_ids.append(int_id)
					break
				id = ""
			else:
				id += c
		
		current = bots.size()-1
		get_bot_info(bots[current])
		reset_info()

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
	$confirm_finish.visible = true
	yield($confirm_finish/confirm, "pressed")
	
	update_current_bot()
	for i in range(bot_ids.size()):
		if not head.DB.update_bot(
				bot_ids[i],
				[
					bots[i]["player_ID_FK"],
					bots[i]["model_ID_FK"],
					bots[i]["ranking"],
					bots[i]["primary_weapon"],
					bots[i]["secondary_weapon"],
					bots[i]["utility"],
					bots[i]["primary_color"],
					bots[i]["secondary_color"],
					bots[i]["accent_color"],
					bots[i]["light_color"]
				],
				bots[i]["name"]):
			print("Updating bot_id %d failed with args:" % bot_ids[i])
			print("  player:           %d" % bots[i]["player_ID_FK"])
			print("  model:            %d" % bots[i]["model_ID_FK"])
			print("  ranking:          %d" % bots[i]["ranking"])
			print("  primary_weapon:   %d" % bots[i]["primary_weapon"])
			print("  secondary_weapon: %d" % bots[i]["secondary_weapon"])
			print("  utility:          %d" % bots[i]["utility"])
			print("  primary_color:    %d" % bots[i]["primary_color"])
			print("  secondary_color:  %d" % bots[i]["secondary_color"])
			print("  accent_color:     %d" % bots[i]["accent_color"])
			print("  light_color:      %d" % bots[i]["light_color"])
			print("  name:             %d" % bots[i]["name"])
	
	get_tree().change_scene("res://Scenes/main_menu.tscn")

func _on_not_confirm_pressed():
	$confirm_finish.visible = false

# Update local bots
#------------------------------------------------
func update_current_bot():
	bots[current]["primary_weapon"] = $item_scroll.current_item()["id"]
	bots[current]["secondary_weapon"] = $item_scroll2.current_item()["id"]
	bots[current]["utility"] = $item_scroll3.current_item()["id"]
	bots[current]["primary_color"] = $color_scroll.get_selected_color().to_rgba32()
	bots[current]["secondary_color"] = $color_scroll2.get_selected_color().to_rgba32()
	bots[current]["accent_color"] = $color_scroll3.get_selected_color().to_rgba32()
	bots[current]["light_color"] = $color_scroll4.get_selected_color().to_rgba32()

# Display/organize data
#------------------------------------------------
func grab_info(info_type):
	match info_type:
		head.PRIMARY:
			get_node("item_scroll2").emit_signal("info_reserved")
			get_node("item_scroll3").emit_signal("info_reserved")
			get_node("item_name").text = $item_scroll.current_item()["name"]
			get_node("item_description").scroll($item_scroll.current_item()["description"])
		head.SECONDARY:
			get_node("item_scroll").emit_signal("info_reserved")
			get_node("item_scroll3").emit_signal("info_reserved")
			get_node("item_name").text = $item_scroll2.current_item()["name"]
			get_node("item_description").scroll($item_scroll2.current_item()["description"])
		head.ABILITY:
			get_node("item_scroll").emit_signal("info_reserved")
			get_node("item_scroll2").emit_signal("info_reserved")
			get_node("item_name").text = $item_scroll3.current_item()["name"]
			get_node("item_description").scroll($item_scroll3.current_item()["description"])

func reset_info():
	$item_name.text = ""
	$item_description.text = ""

func get_bot_info(bot_data):
	$bot_name.text = bot_data["name"]
	$item_scroll.set_current(null, bot_data["primary_weapon"])
	$item_scroll2.set_current(null, bot_data["secondary_weapon"])
	$item_scroll3.set_current(null, bot_data["utility"])
	$color_scroll.set_current(null, bot_data["primary_color"])
	$color_scroll2.set_current(null, bot_data["secondary_color"])
	$color_scroll3.set_current(null, bot_data["accent_color"])
	$color_scroll4.set_current(null, bot_data["light_color"])
