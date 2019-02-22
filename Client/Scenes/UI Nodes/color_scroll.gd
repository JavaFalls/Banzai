extends MarginContainer

export(PoolColorArray) var colors
export(float) var indicator_offset = 0.0 # The time offset for flashing

var current = 0 setget set_current

onready var color_boxes = [
	get_node("HBoxContainer/colors/color0"),
	get_node("HBoxContainer/colors/color1"),
	get_node("HBoxContainer/colors/color2"),
	get_node("HBoxContainer/colors/color3"),
	get_node("HBoxContainer/colors/color4")
]
onready var selected_sprite = get_node("HBoxContainer/colors/color2/selected_sprite")

# Godot functions
#----------------
func _ready():
	reset_color_boxes()
	selected_sprite.get_material().set_shader_param("offset", indicator_offset)

# Signal methods
#---------------
func _on_double_left_pressed():
	if current-1 < 0:
		current = colors.size()-1
	else:
		current -= 1
	reset_color_boxes()

func _on_double_right_pressed():
	if current+1 >= colors.size():
		current = 0
	else:
		current += 1
	reset_color_boxes()

func _on_left_pressed():
	shift_color(false)

func _on_right_pressed():
	shift_color(true)

# Setters
#--------
func set_current(index=null, color=null):
	if typeof(index) == TYPE_INT:
		current = index
	elif typeof(color) == TYPE_INT:
		for i in range(colors.size()):
			if color == colors[i].to_rgba(): # If this is not save as rbga, change it to something else
				current = i
				break

# Get colors by selection
#------------------------
func get_selected_color():
	return color_boxes[2].color

# Get colors by current
#-----------------------
func prev_color(step=null):
	if typeof(step) == TYPE_NIL:
		return colors[current-1]
	else:
		var index = current-step
		while index < 0:
			index += colors.size()
		return colors[index]

func current_color():
	return colors[current]

func next_color(step=null):
	if typeof(step) == TYPE_NIL:
		if current+1 >= colors.size():
			return colors[0]
		return colors[current+1]
	else:
		var index = current+step
		while index >= colors.size():
			index -= colors.size()
		return colors[index]

# Shifting current color
#-------------------------
func shift_color(left):
	if left:
		var first_color = color_boxes[0].color
		color_boxes[0].color = color_boxes[1].color
		color_boxes[1].color = color_boxes[2].color
		color_boxes[2].color = color_boxes[3].color
		color_boxes[3].color = color_boxes[4].color
		color_boxes[4].color = first_color
	else:
		var first_color = color_boxes[4].color
		color_boxes[4].color = color_boxes[3].color
		color_boxes[3].color = color_boxes[2].color
		color_boxes[2].color = color_boxes[1].color
		color_boxes[1].color = color_boxes[0].color
		color_boxes[0].color = first_color

# Changing colors
#----------------
func reset_color_boxes():
	var value = 0.2
	for cb in color_boxes:
		cb.color = current_color()
		cb.color.v = value
		value += 0.2
