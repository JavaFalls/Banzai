extends Control

# Groups
#  names -- the headers for the selectable names
#  name_group -- the selectable names

var speed = 1.0
var slide_delay = 0.2

var names = ["", "", ""]

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

func set_buttons(x_coords):
	var nodes = get_tree().get_nodes_in_group("name_group")
	for n in range(nodes.size()):
		for button in nodes[n].get_children():
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

func select_name(button, position):
	names[position] = button.text

func get_username():
	return names[0] + " " + names[1] + " " + names[2]
