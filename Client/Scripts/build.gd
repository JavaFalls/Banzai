extends Node

onready var _item_list = preload("res://Scripts/item_list.gd")
onready var _macros = preload("res://Scripts/macros.gd")

onready var _background = get_node("Container/background")
onready var _stats = get_node("stats")
onready var _item_current = get_node("ScrollContainer/HBoxContainer/HBoxContainer/current")
onready var _item_next = get_node("ScrollContainer/HBoxContainer/HBoxContainer/CenterContainer2/next")
onready var _item_prev = get_node("ScrollContainer/HBoxContainer/HBoxContainer/CenterContainer/previous")

signal weapon_changed

onready var weapons = _item_list.new([
	_item_list.Item.new(load("res://assets/icon.png"), null, null),
	_item_list.Item.new(load("res://assets/sword.png"), null, null),
	_item_list.Item.new(load("res://assets/wall.png"), null, null)
])

var stats = [
	"Attack: ",
	"Armor:  ",
	"Range:  ",
	"Points: ",
	"Weight: "
]

func _ready():
	connect("weapon_changed", self, "move_weapons")
	
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

func _on_weapon_left_pressed():
	weapons.set_current(weapons.prev())
	emit_signal("weapon_changed")
	pass

func _on_weapon_right_pressed():
	weapons.set_current(weapons.next())
	emit_signal("weapon_changed")
	pass

func move_weapons():
	_item_current.texture = weapons.current().texture
	_item_next.texture = weapons.next().texture
	_item_prev.texture = weapons.prev().texture
	pass
