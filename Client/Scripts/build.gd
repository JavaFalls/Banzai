extends Node

onready var _item_list = preload("res://Scripts/item_list.gd")
onready var _bot_build = preload("res://Scripts/bot_build.gd")
onready var _macros = preload("res://Scripts/macros.gd")

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

var bots = []
var current_bot = 0

onready var primaries = _item_list.new([
	_item_list.Item.new(load("res://assets/icon.png"), "Robot Face", {
		"attack": 1,
		"armor": 2,
		"range": 3,
		"points": 4,
		"weight": 5
	}),
	_item_list.Item.new(load("res://assets/sword.png"), "Sword", {
		"attack": 2,
		"armor": 4,
		"range": 3,
		"points": 6,
		"weight": 15
	}),
	_item_list.Item.new(load("res://assets/wall.png"), "Nothing Particular", {
		"attack": 0,
		"armor": 20,
		"range": 2,
		"points": 8,
		"weight": 1
	})
])

onready var secondaries = _item_list.new([
	_item_list.Item.new(load("res://assets/sword.png"), "Sword1", {
		"attack": 0,
		"armor": 0,
		"range": 0,
		"points": 0,
		"weight": 0
	}),
	_item_list.Item.new(load("res://assets/sword.png"), "Sword2", {
		"attack": 1,
		"armor": 2,
		"range": 32,
		"points": 8,
		"weight": 3
	}),
	_item_list.Item.new(load("res://assets/sword.png"), "Sword3", {
		"attack": 2,
		"armor": 3,
		"range": 6,
		"points": 2,
		"weight": 4
	})
])

onready var abilities = _item_list.new([
	_item_list.Item.new(load("res://assets/sword.png"), "Sword1", {
		"attack": 0,
		"armor": 0,
		"range": 2,
		"points": 0,
		"weight": 1
	}),
	_item_list.Item.new(load("res://assets/sword.png"), "Sword2", {
		"attack": 0,
		"armor": 0,
		"range": 0,
		"points": 0,
		"weight": 0
	}),
	_item_list.Item.new(load("res://assets/sword.png"), "Sword3", {
		"attack": 0,
		"armor": 1,
		"range": 1,
		"points": 0,
		"weight": 1
	})
])

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
	_background.scale = Vector2(size.x / _macros.NORMAL_WIDTH, size.y / _macros.NORMAL_HEIGHT)
	
	for stat in stats:
		_stats.add_item(stat, null, false)
	
	bots = [
		_bot_build.new([
			primaries.items[0],
			secondaries.items[0],
			abilities.items[0]
		]),
		_bot_build.new([
			primaries.items[0],
			secondaries.items[0],
			abilities.items[0]
		])
	]
	pass

func _on_go_button_pressed():
	get_tree().change_scene("res://Scenes/arena_train.tscn")
	pass

func _on_back_button_pressed():
	get_tree().change_scene("res://Scenes/main_menu.tscn")
	pass

func _resize():
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / _macros.NORMAL_WIDTH, size.y / _macros.NORMAL_HEIGHT)
	pass

func move_primaries(direction):
	primaries.set_current(primaries.call(direction))
	
	bots[current_bot].items["primary"] = primaries.current()
	
	update_items("primary")
	update_stats()
	pass

func move_secondaries(direction):
	secondaries.set_current(secondaries.call(direction))
	
	bots[current_bot].items["secondary"] = secondaries.current()
	
	update_items("secondary")
	update_stats()
	pass

func move_abilities(direction):	
	abilities.set_current(abilities.call(direction))
	
	bots[current_bot].items["ability"] = abilities.current()
	
	update_items("ability")
	update_stats()
	pass

func update_stats():
	var prim_stats = primaries.current().stats.values()
	var sec_stats = secondaries.current().stats.values()
	var abil_stats = abilities.current().stats.values()
	for i in range(_stats.get_item_count()):
		_stats.set_item_text(i, stats[i] + str(prim_stats[i] + sec_stats[i] + abil_stats[i]))
	pass

func update_items(list):
	match (list):
		"primary":
			_primary_current.texture = primaries.current().texture
			_primary_next.texture = primaries.next().texture
			_primary_prev.texture = primaries.prev().texture
			_primary_label.text = "Primary: " + primaries.current().text
		"secondary":
			_secondary_current.texture = secondaries.current().texture
			_secondary_next.texture = secondaries.next().texture
			_secondary_prev.texture = secondaries.prev().texture
			_secondary_label.text = "Secondary: " + secondaries.current().text
		"ability":
			_ability_current.texture = abilities.current().texture
			_ability_next.texture = abilities.next().texture
			_ability_prev.texture = abilities.prev().texture
			_ability_label.text = "Ability: " + abilities.current().text
	pass

func switch_bot(bot):
	print(bots[current_bot].items)
	current_bot = bot
	var items = bots[current_bot].items
	primaries.set_current(items["primary"])
	secondaries.set_current(items["secondary"])
	abilities.set_current(items["ability"])
	update_items("primary")
	update_items("secondary")
	update_items("ability")
	update_stats()
	print(bots[current_bot].items)
	print("\n")
	pass
