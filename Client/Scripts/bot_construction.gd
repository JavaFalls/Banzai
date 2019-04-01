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

var name_hover_color = Color("#ffffff")

# Godot methods
#------------------------------------------------
func _ready():
	var player_bots = parse_json(head.DB.get_player_bots(head.player_ID))
	var id = ""
	for c in player_bots["data"][0]["player_bots"]:
		if c == ",":
			if id != "":
				# Get player bot or all other bots
				var id_num = id.to_int()
				if not constructing_player and id_num != head.player_bot_ID:
					bots.append(parse_json(head.DB.get_bot(id_num))["data"][0])
					bot_ids.append(id_num)
				elif constructing_player and id_num == head.player_bot_ID:
					bots.append(parse_json(head.DB.get_bot(id_num))["data"][0])
					bot_ids.append(id_num)
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
	is1.connect("shift", self, "weapon_changed", [head.PRIMARY])
	is2.connect("shift", self, "weapon_changed", [head.SECONDARY])
	is3.connect("shift", self, "weapon_changed", [head.ABILITY])
	
	$color_scroll.connect("color_changed", self, "set_display_bot_colors")
	$color_scroll2.connect("color_changed", self, "set_display_bot_colors")
	$color_scroll3.connect("color_changed", self, "set_display_bot_colors")
	
	if not bots.empty():
		if constructing_player:
			get_bot_info(bots[current])
		else:
			for i in range(bot_ids.size()):
				if bot_ids[i] == head.bot_ID:
					current = i
					get_bot_info(bots[current])
					break
	
	$animation_bot.face_left()
	randomize()
	
	if bots.size() == 1:
		$bot_left.visible = false
		$bot_right.visible = false
	else: 
		$bot_left.visible = true
		$bot_right.visible = true
	
	
	if constructing_player:
		$new_button.visible = false
		$change_name.visible = false
		$advanced_options.visible = false

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
	var new_name = yield(change_name(), "completed")
	var default_color = Color("#ffffffff").to_rgba32() # Default to white
	if not head.DB.new_bot(head.player_ID, [0,0,0,0,default_color,default_color,default_color,$animation_bot.ANIMATION_SET_B1], new_name):
		print("Creating a new bot failed")
	else:
		# Get the newest bot
		var player_bots = parse_json(head.DB.get_player_bots(head.player_ID))
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
	
	if bots.size() == 1:
		$bot_left.visible = false
		$bot_right.visible = false
	else: 
		$bot_left.visible = true
		$bot_right.visible = true
	
	update_current_bot()
	current = bots.size()-1
	get_bot_info(bots[current])
	reset_info()

func _on_test_button_pressed():
	update_current_bot()
	update_bots()
	
	if constructing_player:
		head.player_bot_ID = bot_ids[current]
	else:
		head.bot_ID = bot_ids[current]
	get_tree().change_scene("res://Scenes/arena_test.tscn")

func _on_finish_button_pressed():
	$confirm_finish.visible = true
	yield($confirm_finish/confirm, "pressed")
	
	update_current_bot()
	update_bots()
	
	if constructing_player:
		head.player_bot_ID = bot_ids[current]
	else:
		head.bot_ID = bot_ids[current]
	
	var sound = head.create_player("UI")
	head.play_stream(sound, head.sounds.SCENE_CHANGE)
	head.delete_player(sound)
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

func _on_change_name_button_pressed():
	var new_name = yield(change_name(), "completed")
	$bot_name.text = new_name
	update_current_bot()

func _on_change_name_button_mouse_entered():
	$change_name.modulate = Color("#ffffff")

func _on_change_name_button_mouse_exited():
	$change_name.modulate = Color("#aaaaaa")

func _on_advanced_options_pressed():
	$nn_options.visible = true

func button_hover_enter():
	var sound = head.create_player("UI")
	head.play_stream(sound, head.sounds.BUTTON_HOVER)
	head.delete_player(sound)

# Update local bots
#------------------------------------------------
func update_current_bot():
	bots[current]["name"] = $bot_name.text
	bots[current]["primary_weapon"] = $item_scroll.current_item()["id"]
	bots[current]["secondary_weapon"] = $item_scroll2.current_item()["id"]
	bots[current]["utility"] = $item_scroll3.current_item()["id"]
	bots[current]["primary_color"] = $color_scroll.get_selected_color().to_rgba32()
	bots[current]["secondary_color"] = $color_scroll2.get_selected_color().to_rgba32()
	bots[current]["accent_color"] = $color_scroll3.get_selected_color().to_rgba32()

func change_name():
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
	return new_name

func weapon_changed(info_type):
	match info_type:
		head.PRIMARY:
			$item_scroll._on_info_button_pressed()
		head.SECONDARY:
			$item_scroll2._on_info_button_pressed()
		head.ABILITY:
			$item_scroll3._on_info_button_pressed()

	var stream
	match randi() % 15:
		0:
			stream = head.sounds.BOT_CHANGE_1
		1:
			stream = head.sounds.BOT_CHANGE_2
		2:
			stream = head.sounds.BOT_CHANGE_3
		_:
			pass
	if typeof(stream) != TYPE_NIL:
		var sound = head.create_player("UI")
		head.play_stream(sound, stream)
		head.delete_player(sound)

# Update DB bots
#------------------------------------------------
func update_bots():
	var default_color = Color("#ffffffff").to_rgba32() # Default to white
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
					bots[i]["animation"]
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
			print("  animation:        %d" % bots[i]["animation"])
			print("  name:             %d" % bots[i]["name"])

# Display/organize data
#------------------------------------------------
func format_info(speed, attack, type, info):
	if typeof(speed) == TYPE_REAL and typeof(attack) == TYPE_INT:
		return (
			STATS_SPACE + "%.2f" % speed + "\n" +
			STATS_SPACE + "%d" % attack + "\n" +
			STATS_SPACE + "%s" % type + "\n" +
			"   %s" % info
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
	$animation_bot.set_bot_type(bot_data["animation"])
	$color_scroll.set_current(bot_data["primary_color"])
	$color_scroll2.set_current(bot_data["secondary_color"])
	$color_scroll3.set_current(bot_data["accent_color"])

func set_display_bot_colors():
	$animation_bot.set_primary_color($color_scroll.get_selected_color())
	$animation_bot.set_secondary_color($color_scroll2.get_selected_color())
	$animation_bot.set_accent_color($color_scroll3.get_selected_color())
