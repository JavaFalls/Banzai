extends Control

"""
Groups
	names -- the headers for the selectable names
	name_group -- the selectable names
"""

"""
Exported variables
"""
export(float, 0.001, 1000.0) var speed = 1.0
export(float, 0.0, 1000.0) var slide_delay = 0.2

"""
Constants
"""
const names_0 = PoolStringArray([
	"The name even","The name even",
	"The name even","The name even",
	"The name even","The name even",
	"The name even","The name even",
	"The name even","The name even"
])
const names_1 = PoolStringArray([
	"The name even","The name even",
	"The name even","The name even",
	"Aristotle","The name even",
	"The name even","The name even",
	"Turing Machine","The name even"
])
const names_2 = PoolStringArray([
	"The name even","The name even",
	"The name even","The name even",
	"Mr. Invincible","The name even",
	"The name even","The name even",
	"ez24/7","The name even"
])

"""
Variables
"""
var sub_names = ["", "", ""]

func _ready():
	var to_x = {}
	for n in get_tree().get_nodes_in_group("names"):
		to_x[n] = n.rect_global_position.x
		n.rect_global_position.x = -n.rect_size.x
		n.modulate.a = 0
	
	set_buttons(to_x)
	
	for n in get_tree().get_nodes_in_group("names"):
		slide_control(n, -n.rect_size.x, to_x[n], speed, 1)
	yield(get_tree().create_timer(slide_delay), "timeout")
	
	slide_buttons(to_x)
	pass

"""
Signal methods
"""
func select_name(button, position):
	sub_names[position] = button.text
	get_tree().get_nodes_in_group("names")[position].text = button.text
	if sub_names[0] != "" and sub_names[1] != "" and sub_names[2] != "":
		get_node("menu_button").disabled = false

func start():
	head.username = get_username()
	get_tree().change_scene("res://Scenes/main_menu.tscn")

"""
Node methods
"""
func set_buttons(x_coords):
	var nodes = get_tree().get_nodes_in_group("name_group")
	var names = [names_0, names_1, names_2]
	
	for n in range(nodes.size()):
		var i = 0
		for button in nodes[n].get_children():
			button.text = names[n][i]
			i += 1
			
			x_coords[button] = button.rect_global_position.x
			button.rect_global_position.x = -button.rect_size.x
			button.modulate.a = 0
			button.connect("pressed", self, "select_name", [button, n])

func slide_buttons(x_coords):
	var nodes = get_tree().get_nodes_in_group("name_group")
	for n in range(nodes.size() - 1, -1, -1):
		for button in nodes[n].get_children():
			slide_control(button, -button.rect_size.x, x_coords[button], speed, 1)
			yield(get_tree().create_timer(slide_delay), "timeout")

func slide_control(control, from, to, f_speed, delay):
	var tween = Tween.new()
	add_child(tween, false)
	tween.interpolate_property(control, "rect_global_position:x", from,  to, f_speed, Tween.TRANS_EXPO, Tween.EASE_OUT, delay)
	tween.start()
	control.modulate.a = 1
	yield(tween, "tween_completed")
	tween.queue_free()

func get_username():
	return sub_names[0] + " " + sub_names[1] + " " + sub_names[2]

"""
table of names:
|---+-----+--+---+-----|
|id |     | name | set |
|---+-----+--+---+-----|

dictionary:
	id = set_number

username:
	0x 00 00 00 set of ids
	   #A #B #C

A is chosen
Get all names with A
Disable B and C selections
"""
func disable_selections(set):
	if typeof(set) == TYPE_INT and set >= 0 and set <= 2:
		var invalid_names = get_used_names(set) # database call
		var nodes = get_tree().get_nodes_in_group("name_group")
		
		for n in range(nodes.size()):
			if n != set:
				for button in nodes[n].get_children():
					for i in invalid_names:
						button.disabled = (button.text == get_name(set, i)) # database call

func get_userhex():
	return
