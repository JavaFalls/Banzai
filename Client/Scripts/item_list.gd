extends "head.gd"

class Item:
	var texture
	var text
	var stats
	
	func _init(i_texture=null, i_text=null, i_stats=null):
		if i_texture is Texture:
			texture = i_texture
		if typeof(i_text) == TYPE_STRING:
			text = i_text
		if typeof(i_stats) == TYPE_DICTIONARY:
			stats = i_stats
		pass

var items = []
var current = 0
var animation_player

func _init(i_items=null, i_anim_player=null):
	items = i_items
	animation_player = i_anim_player
	pass

func current():
	return items[current]

func set_current(item=null, index=null):
	if typeof(item) != TYPE_NIL:
		current = items.find(item)
	elif typeof(index) != TYPE_NIL:
		current = index
	pass

func next():
	if current+1 >= items.size():
		return items.front()
	return items[current+1]

func prev():
	return items[current-1]


func move(animation, direction="next"):
	var item = call(direction)
	if item:
		animation_player.play(animation)
	pass
