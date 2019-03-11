extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")
onready var weapon_creator = get_tree().get_root().get_node("/root/weapon_creator")

onready var constructing_player = (head.construction == head.PLAYER)
onready var name_choice_scene = preload("res://Scenes/name_choice.tscn")

const STATS_SPACE = "           "

onready var w_pri = weapon_creator.get_w_pri_stats()
onready var w_sec = weapon_creator.get_w_sec_stats()
onready var w_abi = weapon_creator.get_w_abi_stats()

# Every loaded bot is temporarily stored
var bots = [] # Both the id and its bot will have the same index
var bot_ids = []
var current = 0

var current_info_type = 0

# Godot methods
#------------------------------------------------
func _ready():
	if constructing_player:
		$bot_left.visible = false
		$bot_right.visible = false
		$new_button.visible = false
	
#### FOR TESTING #
	var player_id = head.player_ID
	if player_id == -1:
		player_id = 1
	var bot_id = head.bot_ID
	if bot_id == -1:
		bot_id = 1
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
	is1.set_items(w_pri)
	is2.set_data_points(10, 16)
	is2.set_items(w_sec)
	is3.set_data_points(10, 16)
	is3.set_items(w_abi)
	
	is1.connect("info_queried", self, "grab_info", [head.PRIMARY])
	is2.connect("info_queried", self, "grab_info", [head.SECONDARY])
	is3.connect("info_queried", self, "grab_info", [head.ABILITY])
	
	$color_scroll.connect("color_changed", self, "set_display_bot_colors")
	$color_scroll2.connect("color_changed", self, "set_display_bot_colors")
	$color_scroll3.connect("color_changed", self, "set_display_bot_colors")
	
	if not bots.empty():
		get_bot_info(bots[0])
	
	$animation_bot.face_left()

# Signal methods
#------------------------------------------------
func _on_bot_left_pressed():
	update_current_bot()
	current = bots.size()-1 if current-1 < 0 else current-1
	get_bot_info(bots[current])
	grab_info(current_info_type)
	
func _on_bot_right_pressed():
	update_current_bot()
	current = 0 if current+1 >= bots.size() else current+1
	get_bot_info(bots[current])
	grab_info(current_info_type)

# Entering a name
func _on_new_button_pressed():
	var new_name = ""
	if name_choice_scene.can_instance():
		$backlight/Light2D.enabled = false
		var name_choice_node = name_choice_scene.instance(PackedScene.GEN_EDIT_STATE_DISABLED)
		name_choice_node.get_node("confirm_button/Label").text = "n\ne\nw\n\nb\no\nt"
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

func _on_test_button_pressed():
	get_tree().change_scene("res://Scenes/arena_test.tscn")

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

func _on_switch_description_pressed():
	var button = $switch_description
	if button.pressed:
		button.text = "desc"
		$item_description/stats.visible = false
	else:
		button.text = "stats"
		$item_description/stats.visible = true
	grab_info(current_info_type)

func _on_not_confirm_pressed():
	$confirm_finish.visible = false

func _on_switch_description_mouse_entered():
	$switch_description.modulate = Color("#ffffff")

func _on_switch_description_mouse_exited():
	$switch_description.modulate = Color("#aaaaaa")

# Update local bots
#------------------------------------------------
func update_current_bot():
	bots[current]["primary_weapon"] = $item_scroll.current_item()["id"]
	bots[current]["secondary_weapon"] = $item_scroll2.current_item()["id"]
	bots[current]["utility"] = $item_scroll3.current_item()["id"]
	bots[current]["primary_color"] = $color_scroll.get_selected_color().to_rgba32()
	bots[current]["secondary_color"] = $color_scroll2.get_selected_color().to_rgba32()
	bots[current]["accent_color"] = $color_scroll3.get_selected_color().to_rgba32()
#	bots[current]["light_color"] = $color_scroll4.get_selected_color().to_rgba32()

# Display/organize data
#------------------------------------------------
func format_info(speed, attack, type, info):
	if typeof(speed) == TYPE_REAL and typeof(attack) == TYPE_INT:
		return (
			STATS_SPACE + "%.2f" % speed + "\n" +
			STATS_SPACE + "%d" % attack + "\n" +
			STATS_SPACE + "%s" % type + "\n" +
			STATS_SPACE + "%s" % info
		)
	else:
		return ""

func grab_info(info_type):
	match info_type:
		head.PRIMARY:
			get_node("item_scroll2").emit_signal("info_reserved")
			get_node("item_scroll3").emit_signal("info_reserved")
			get_node("item_name").text = $item_scroll.current_item()["name"]
			if $switch_description.pressed:
				get_node("item_description").scroll($item_scroll.current_item()["description"])
			else:
				$item_description.scroll(format_info(
					$item_scroll.current_item()["speed"],
					$item_scroll.current_item()["attack"],
					$item_scroll.current_item()["type"],
					$item_scroll.current_item()["info"]
				))
		head.SECONDARY:
			get_node("item_scroll").emit_signal("info_reserved")
			get_node("item_scroll3").emit_signal("info_reserved")
			get_node("item_name").text = $item_scroll2.current_item()["name"]
			if $switch_description.pressed:
				get_node("item_description").scroll($item_scroll2.current_item()["description"])
			else:
				$item_description.scroll(format_info(
					$item_scroll2.current_item()["speed"],
					$item_scroll2.current_item()["attack"],
					$item_scroll2.current_item()["type"],
					$item_scroll2.current_item()["info"]
				))
		head.ABILITY:
			get_node("item_scroll").emit_signal("info_reserved")
			get_node("item_scroll2").emit_signal("info_reserved")
			get_node("item_name").text = $item_scroll3.current_item()["name"]
			if $switch_description.pressed:
				get_node("item_description").scroll($item_scroll3.current_item()["description"])
			else:
				$item_description.scroll(format_info(
					$item_scroll3.current_item()["speed"],
					$item_scroll3.current_item()["attack"],
					$item_scroll3.current_item()["type"],
					$item_scroll3.current_item()["info"]
				))
	current_info_type = info_type

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
#	$color_scroll4.set_current(null, bot_data["light_color"])

func set_display_bot_colors():
	$animation_bot.set_primary_color($color_scroll.get_selected_color())
	$animation_bot.set_secondary_color($color_scroll2.get_selected_color())
	$animation_bot.set_accent_color($color_scroll3.get_selected_color())
