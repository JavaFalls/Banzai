extends Node

onready var _macros = preload("res://Scripts/macros.gd")
onready var _background = get_node("Container/background")
onready var _stats = get_node("stats")

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
