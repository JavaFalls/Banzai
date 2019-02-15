extends MarginContainer

const CONTROL_SIZE = Vector2(150, 30)

var items = []
var current = 0
var animation_player

onready var prev_item_node = get_node("HBoxContainer/items/prev")
onready var current_item_node = get_node("HBoxContainer/items/current")
onready var next_item_node = get_node("HBoxContainer/items/next")

func _ready():
	pass

# Signal methods
#---------------
func _on_go_to_prev_pressed():
	if current-1 < 0:
		set_current(items.size() - 1)
	else:
		set_current(current-1)
	update_items()

func _on_go_to_next_pressed():
	if current+1 >= items.size():
		set_current(0)
	else:
		set_current(current+1)
	update_items()

# Item methods
#-------------
func set_current(index):
	if typeof(index) != TYPE_NIL:
		current = index

func current_item():
	return items[current]
	
func next_item():
	if current+1 >= items.size():
		return items.front()
	return items[current+1]

func prev_item():
	return items[current-1]

func update_items():
	prev_item_node.texture = prev_item()["texture"]
	current_item_node.texture = current_item()["texture"]
	next_item_node.texture = next_item()["texture"]
