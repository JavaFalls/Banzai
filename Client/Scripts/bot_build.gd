var texture

var items = []

func _init(new_items=null):
	if typeof(new_items) == TYPE_ARRAY and new_items.size() >= items.size():
		items = new_items
	pass
