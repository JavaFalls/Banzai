extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

var t = preload("res://assets/sword.png")
var i = preload("res://icon.png")
var w = [
	{"texture": t},
	{"texture": t},
	{"texture": t},
	{"texture": t},
	{"texture": t},
	{"texture": t}
]

func _ready():
	get_node("item_scroll").set_data_points(3, 30)
	get_node("item_scroll").set_items(w)
