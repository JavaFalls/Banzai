extends Node2D

export(float, 0.0, 5.0) var scroll_time = 0.2 setget set_scroll_time

# ! Important !
var data_points = [Vector2(0,0)] # Set these points before anything else

var items = [] setget set_items # Will be a list dictionaries each with a texture property
var current = 0 setget set_current

var shifting = false
signal shift_completed

onready var sprites = [
	get_node("item0"),
	get_node("item1"),
	get_node("item2"),
	get_node("item3"),
	get_node("item4")
]

# Signals
#---------------
func _on_go_to_prev_pressed():
	if not shifting:
		if current-1 < 0:
			set_current(items.size() - 1)
		else:
			set_current(current-1)
		sprites.front().modulate.a = 1.0
		move_left()
		shifting = true
		yield(self, "shift_completed")
		shifting = false

func _on_go_to_next_pressed():
	if not shifting:
		if current+1 >= items.size():
			set_current(0)
		else:
			set_current(current+1)
		sprites.back().modulate.a = 1.0
		move_right()
		shifting = true
		yield(self, "shift_completed")
		shifting = false

# Setters
#-------------
func set_data_points(margin, data_width):
	for n in range(1, 5, 1):
		data_points.append(Vector2(n * (data_width + margin),0))
		sprites[n].position = data_points[n]
	var rb = get_node("go_to_next")
	rb.rect_position = data_points.back() - (rb.rect_size/2)

func set_items(new_items):
	items = new_items
	sprites[0].texture = prev_item(2)["texture"]
	sprites[1].texture = prev_item()["texture"]
	sprites[2].texture = current_item()["texture"]
	sprites[3].texture = next_item()["texture"]
	sprites[4].texture = next_item(2)["texture"]

func set_current(index):
	if typeof(index) != TYPE_NIL:
		current = index

func set_scroll_time(time):
	if time <= 0.0:
		scroll_time = 0.000001
	else:
		scroll_time = time

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
		sprites.back().position = data_points.back()
		sprites.back().texture = next_item(2)["texture"]
	else:
		sprites.push_front(sprites.pop_back())
		sprites.front().position = data_points.front()
		sprites.front().texture = prev_item(2)["texture"]
	sprites.front().modulate.a = 0.0
	sprites.back().modulate.a = 0.0
	emit_signal("shift_completed")
