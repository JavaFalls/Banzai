extends MarginContainer

const CONTROL_SIZE = Vector2(150, 30)

var items = []
var current = 0

onready var prev_item_node = get_node("HBoxContainer/items/prev")
onready var current_item_node = get_node("HBoxContainer/items/current")
onready var next_item_node = get_node("HBoxContainer/items/next")
onready var animator = get_node("AnimationPlayer")

func _ready():
	rect_size = CONTROL_SIZE
	
	### test for sprite nodes
	var item_sprites = get_tree().get_nodes_in_group("item_textures")
	item_sprites[1].global_position = prev_item_node.get_child(0).rect_global_position
	item_sprites[2].global_position = current_item_node.get_child(0).rect_global_position
	item_sprites[3].global_position = next_item_node.get_child(0).rect_global_position
	item_sprites[0].global_position = item_sprites[1].global_position - Vector2(item_sprites[1].texture.get_width(), 0)
	item_sprites[4].global_position = item_sprites[3].global_position + Vector2(item_sprites[3].texture.get_width(), 0)

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
