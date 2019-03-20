extends MarginContainer

export(PoolColorArray) var colors
export(float) var indicator_offset = 0.0 # The time offset for flashing

var current = 0

onready var color_boxes = [
	get_node("HBoxContainer/colors/color0"),
	get_node("HBoxContainer/colors/color1"),
	get_node("HBoxContainer/colors/color2"),
	get_node("HBoxContainer/colors/color3"),
	get_node("HBoxContainer/colors/color4")
]
onready var selected_sprite = get_node("HBoxContainer/colors/color2/selected_sprite")

signal color_changed

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
	emit_signal("color_changed")

func _on_double_right_pressed():
	if current+1 >= colors.size():
		current = 0
	else:
		current += 1
	reset_color_boxes()
	emit_signal("color_changed")

func _on_left_pressed():
	shift_color(false)
	emit_signal("color_changed")

func _on_right_pressed():
	shift_color(true)
	emit_signal("color_changed")

# Setters
#--------
func set_current(index=null, color=null):
	if typeof(index) == TYPE_INT:
		current = index
	elif typeof(color) == TYPE_INT or typeof(color) == TYPE_REAL:
		var c_color = Color(int(color)) if typeof(color) == TYPE_REAL else Color(color) # RGBA integer construction
		var h = c_color.h
		var s = c_color.s
		for i in range(colors.size()):
			if h == colors[i].h and s == colors[i].s:
				current = i
				reset_color_boxes()
				set_box_color(c_color.v)
				emit_signal("color_changed")
				break

func set_box_color(value):
	if value < 0.9:
		if value < 0.7:
			if value < 0.5:
				if value < 0.3:
					color_boxes[0].color.v = 0.8
					color_boxes[1].color.v = 1.0
					color_boxes[3].color.v = 0.4
					color_boxes[4].color.v = 0.6
				else:
					color_boxes[0].color.v = 1.0
					color_boxes[1].color.v = 0.2
					color_boxes[3].color.v = 0.6
					color_boxes[4].color.v = 0.8
			else:
				color_boxes[0].color.v = 0.2
				color_boxes[1].color.v = 0.4
				color_boxes[3].color.v = 0.8
				color_boxes[4].color.v = 1.0
		else:
			color_boxes[0].color.v = 0.4
			color_boxes[1].color.v = 0.6
			color_boxes[3].color.v = 1.0
			color_boxes[4].color.v = 0.2
	else:
		color_boxes[0].color.v = 0.6
		color_boxes[1].color.v = 0.8
		color_boxes[3].color.v = 0.2
		color_boxes[4].color.v = 0.4
	color_boxes[2].color.v = value

# Get colors by boxes
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
