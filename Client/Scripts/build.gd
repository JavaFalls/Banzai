extends Node

const NORMAL_WIDTH = 1600
const NORMAL_HEIGHT = 900

onready var _background = get_node("Container/game_background_31")
onready var _stats = get_node("stats")

var stats = [
	"Attack: ",
	"Armor:  ",
	"Range:  ",
	"Points: ",
	"Weight: "
]

func _ready():
	get_tree().get_root().connect("size_changed", self, "resize")
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / NORMAL_WIDTH, size.y / NORMAL_HEIGHT)
	
	for stat in stats:
		_stats.add_item(stat, null, false)
	pass

func resize():
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / NORMAL_WIDTH, size.y / NORMAL_HEIGHT)
	pass

func _on_go_button_pressed():
	get_tree().change_scene("res://Scenes/arena_train.tscn")
	pass

func _on_back_button_pressed():
	get_tree().change_scene("res://Scenes/main_menu.tscn")
	pass
