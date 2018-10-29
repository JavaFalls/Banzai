extends Node

onready var _item_list = preload("res://Scripts/item_list.gd")
onready var _macros = preload("res://Scripts/macros.gd")

onready var _background = get_node("Container/background")
onready var _stats = get_node("stats")

onready var _primary_current = get_node("primary_weapons/HBoxContainer/HBoxContainer/current")
onready var _primary_next = get_node("primary_weapons/HBoxContainer/HBoxContainer/next")
onready var _primary_prev = get_node("primary_weapons/HBoxContainer/HBoxContainer/previous")
onready var _secondary_current = get_node("secondary_weapons/HBoxContainer/HBoxContainer/current")
onready var _secondary_next = get_node("secondary_weapons/HBoxContainer/HBoxContainer/next")
onready var _secondary_prev = get_node("secondary_weapons/HBoxContainer/HBoxContainer/previous")
onready var _ability_current = get_node("abilities/HBoxContainer/HBoxContainer/current")
onready var _ability_next = get_node("abilities/HBoxContainer/HBoxContainer/next")
onready var _ability_prev = get_node("abilities/HBoxContainer/HBoxContainer/previous")

onready var weapons = _item_list.new([
	_item_list.Item.new(load("res://assets/icon.png"), null, null),
	_item_list.Item.new(load("res://assets/sword.png"), null, null),
	_item_list.Item.new(load("res://assets/wall.png"), null, null)
])

onready var secondaries = _item_list.new([
	_item_list.Item.new(load("res://assets/sword.png"), null, null),
	_item_list.Item.new(load("res://assets/sword.png"), null, null),
	_item_list.Item.new(load("res://assets/sword.png"), null, null)
])

onready var abilities = _item_list.new([
	_item_list.Item.new(load("res://assets/sword.png"), null, null),
	_item_list.Item.new(load("res://assets/sword.png"), null, null),
	_item_list.Item.new(load("res://assets/sword.png"), null, null)
])

var stats = [
	"Attack: ",
	"Armor:  ",
	"Range:  ",
	"Points: ",
	"Weight: "
]

func _ready():
	get_tree().get_root().connect("size_changed", self, "_resize")
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / _macros.NORMAL_WIDTH, size.y / _macros.NORMAL_HEIGHT)
	
	for stat in stats:
		_stats.add_item(stat, null, false)
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

func move_weapons(direction):
	weapons.set_current(weapons.call(direction))
	_primary_current.texture = weapons.current().texture
	_primary_next.texture = weapons.next().texture
	_primary_prev.texture = weapons.prev().texture
	pass

func move_secondaries(direction):
	secondaries.set_current(secondaries.call(direction))
	_secondary_current.texture = secondaries.current().texture
	_secondary_next.texture = secondaries.next().texture
	_secondary_prev.texture = secondaries.prev().texture
	pass

func move_abilities(direction):
	abilities.set_current(abilities.call(direction))
	_ability_current.texture = abilities.current().texture
	_ability_next.texture = abilities.next().texture
	_ability_prev.texture = abilities.prev().texture
	pass
