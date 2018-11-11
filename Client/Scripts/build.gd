extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

onready var _background = get_node("Container/background")
onready var _stats = get_node("stats")

onready var _primary_current = get_node("primary_weapons/HBoxContainer/HBoxContainer/current")
onready var _primary_next = get_node("primary_weapons/HBoxContainer/HBoxContainer/next")
onready var _primary_prev = get_node("primary_weapons/HBoxContainer/HBoxContainer/previous")
onready var _primary_label = get_node("primary_weapons/Label")

onready var _secondary_current = get_node("secondary_weapons/HBoxContainer/HBoxContainer/current")
onready var _secondary_next = get_node("secondary_weapons/HBoxContainer/HBoxContainer/next")
onready var _secondary_prev = get_node("secondary_weapons/HBoxContainer/HBoxContainer/previous")
onready var _secondary_label = get_node("secondary_weapons/Label")

onready var _ability_current = get_node("abilities/HBoxContainer/HBoxContainer/current")
onready var _ability_next = get_node("abilities/HBoxContainer/HBoxContainer/next")
onready var _ability_prev = get_node("abilities/HBoxContainer/HBoxContainer/previous")
onready var _ability_label = get_node("abilities/Label")

onready var builds = head.bot_builds
var current_bot
var current_ai = 0

onready var primaries = head.primary_list
onready var secondaries = head.secondary_list
onready var abilities = head.ability_list

var stats = [
	"Attack: ",
	"Armor: ",
	"Range: ",
	"Points: ",
	"Weight: "
]

func _ready():
	get_tree().get_root().connect("size_changed", self, "_resize")
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / head.NORMAL_WIDTH, size.y / head.NORMAL_HEIGHT)
	
	for stat in stats:
		_stats.add_item(stat, null, false)
	
	switch_bot(head.PLAYER)
	update_stats()
	pass

# TEST CODE ------------------------------------------------------------------------------#
#func _process(delta):
#	if Input.is_action_just_pressed("ui_up"):
#		head.save_bots(bots)
#	elif Input.is_action_just_pressed("ui_down"):
#		bots = head.load_bots()
#-----------------------------------------------------------------------------------------#

func _on_go_button_pressed():
	change_scene("res://Scenes/arena_train.tscn")
	pass

func _on_back_button_pressed():
	change_scene("res://Scenes/main_menu.tscn")
	pass

func _resize():
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / head.NORMAL_WIDTH, size.y / head.NORMAL_HEIGHT)
	pass

func move_primaries(direction):
	primaries.set_current(primaries.call(direction))
	
	builds[current_bot][head.PRIMARY] = primaries.current()
	
	update_items(head.PRIMARY)
	update_stats()
	pass

func move_secondaries(direction):
	secondaries.set_current(secondaries.call(direction))
	
	builds[current_bot][head.SECONDARY] = secondaries.current()
	
	update_items(head.SECONDARY)
	update_stats()
	pass

func move_abilities(direction):
	abilities.set_current(abilities.call(direction))
	
	builds[current_bot][head.ABILITY] = abilities.current()
	
	update_items(head.ABILITY)
	update_stats()
	pass

func update_stats():
	var prim_stats = primaries.current().values()
	var sec_stats = secondaries.current().values()
	var abil_stats = abilities.current().values()
	for i in range(_stats.get_item_count()):
		var j = i + 3
		_stats.set_item_text(i, stats[i] + str(prim_stats[j] + sec_stats[j] + abil_stats[j]))
	pass

func update_items(list):
	match (list):
		head.PRIMARY:
			_primary_current.texture = primaries.current()["texture"]
			_primary_next.texture = primaries.next()["texture"]
			_primary_prev.texture = primaries.prev()["texture"]
			_primary_label.text = "Primary: " + primaries.current()["name"]
		head.SECONDARY:
			_secondary_current.texture = secondaries.current()["texture"]
			_secondary_next.texture = secondaries.next()["texture"]
			_secondary_prev.texture = secondaries.prev()["texture"]
			_secondary_label.text = "Secondary: " + secondaries.current()["name"]
		head.ABILITY:
			_ability_current.texture = abilities.current()["texture"]
			_ability_next.texture = abilities.next()["texture"]
			_ability_prev.texture = abilities.prev()["texture"]
			_ability_label.text = "Ability: " + abilities.current()["name"]
	pass

func switch_bot(bot):
	current_bot = bot
	var items = builds[current_bot]
	primaries.set_current(items[head.PRIMARY])
	secondaries.set_current(items[head.SECONDARY])
	abilities.set_current(items[head.ABILITY])
	update_items(head.PRIMARY)
	update_items(head.SECONDARY)
	update_items(head.ABILITY)
	update_stats()
	pass

func switch_ai_bot(add_index):
	current_ai += add_index
	if current_ai < 0:
		current_ai = head.ai_builds.size() + current_ai
	elif current_ai > head.ai_builds.size() - 1:
		current_ai = current_ai - head.ai_builds.size() - 1
	builds[head.BOT] = head.ai_builds[current_ai]

func change_scene(path):
	if not head.is_ai_bot(builds[head.BOT]):
		head.save_bot(builds[head.BOT])
	head.bot_builds = builds
	get_tree().change_scene(path)
