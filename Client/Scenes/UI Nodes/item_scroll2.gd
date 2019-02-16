extends Node2D

export(float, 0.0, 5.0) var scroll_time = 0.2

var data_points = [Vector2(0,0)] # Set these points before anything else

var items = [] setget set_items # Will be a list dictionaries each with a texture property
var current = 0

signal shift_completed

onready var sprites = [
	get_node("item0"),
	get_node("item1"),
	get_node("item2"),
	get_node("item3"),
	get_node("item4")
]
#onready var animator = get_node("AnimationPlayer")

func _ready():
	pass

#TEST##############
var key_pressed = false
func _input(event):
	if event is InputEventKey:
		if not key_pressed:
			if event.scancode == KEY_LEFT:
				key_pressed = true
				_on_go_to_next_pressed()
				yield(self, "shift_completed")
				key_pressed = false
			if event.scancode == KEY_RIGHT:
				key_pressed = true
				_on_go_to_prev_pressed()
				yield(self, "shift_completed")
				key_pressed = false

# Signals
#---------------
func _on_go_to_prev_pressed():
	if current-1 < 0:
		set_current(items.size() - 1)
	else:
		set_current(current-1)
	sprites.front().modulate.a = 1.0
	move_left()

func _on_go_to_next_pressed():
	if current+1 >= items.size():
		set_current(0)
	else:
		set_current(current+1)
	sprites.back().modulate.a = 1.0
	move_right()

# Setters
#-------------
func set_data_points(margin, data_width):
	for n in range(1, 5, 1):
		data_points.append(Vector2(n * (data_width + margin),0))

func set_items(new_items):
	items = new_items

func set_current(index):
	if typeof(index) != TYPE_NIL:
		current = index

# Getting items by current
#-------------
func current_item():
	return items[current]
	
func next_item(step=null):
	if typeof(step) == TYPE_NIL:
		if current+1 >= items.size():
			return items.front()
		return items[current+1]
	else:
		var index = current+step
		while index >= items.size():
			index -= items.size()
		return items[index]

func prev_item(step=null):
	if typeof(step) == TYPE_NIL:
		return items[current-1]
	else:
		var index = current-step
		while index < 0:
			index += items.size()
		return items[index]

# Shifting items
#---------------
func move_left():
	sprites[0].get_child(0).interpolate_property(sprites[0], ":position", sprites[0].position, data_points[1], scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[0].get_child(0).interpolate_property(sprites[0], ":modulate", Color(1,1,1,0), Color(1,1,1,1), scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[1].get_child(0).interpolate_property(sprites[1], ":position", sprites[1].position, data_points[2], scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[2].get_child(0).interpolate_property(sprites[2], ":position", sprites[2].position, data_points[3], scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[3].get_child(0).interpolate_property(sprites[3], ":position", sprites[3].position, data_points[4], scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[3].get_child(0).interpolate_property(sprites[3], ":modulate", Color(1,1,1,1), Color(1,1,1,0), scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[0].get_child(0).start()
	sprites[1].get_child(0).start()
	sprites[2].get_child(0).start()
	sprites[3].get_child(0).start()
	yield(sprites[1].get_child(0), "tween_completed")
	update_items(false)

func move_right():
	sprites[1].get_child(0).interpolate_property(sprites[1], ":position", sprites[1].position, data_points[0], scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[1].get_child(0).interpolate_property(sprites[1], ":modulate", Color(1,1,1,1), Color(1,1,1,0), scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[2].get_child(0).interpolate_property(sprites[2], ":position", sprites[2].position, data_points[1], scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[3].get_child(0).interpolate_property(sprites[3], ":position", sprites[3].position, data_points[2], scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[4].get_child(0).interpolate_property(sprites[4], ":position", sprites[4].position, data_points[3], scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[4].get_child(0).interpolate_property(sprites[4], ":modulate", Color(1,1,1,0), Color(1,1,1,1), scroll_time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	sprites[1].get_child(0).start()
	sprites[2].get_child(0).start()
	sprites[3].get_child(0).start()
	sprites[4].get_child(0).start()
	yield(sprites[3].get_child(0), "tween_completed")
	update_items(true)

func update_items(pop_first):
	if pop_first:
		sprites.push_back(sprites.pop_front())
		sprites.back().position = data_points[4]
		sprites.back().texture = next_item(2)["texture"]
	else:
		sprites.push_front(sprites.pop_back())
		sprites.front().position = data_points[0]
		sprites.front().texture = prev_item(2)["texture"]
	sprites.front().modulate.a = 0.0
	sprites.back().modulate.a = 0.0
	emit_signal("shift_completed")
