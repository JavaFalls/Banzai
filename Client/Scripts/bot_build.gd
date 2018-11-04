var texture

var items = {
	"primary": null,
	"secondary": null,
	"ability": null
}

func _init(new_items=null):
	if typeof(new_items) == TYPE_ARRAY and new_items.size() >= items.size():
		var param_index = 0
		for key in items:
			add_item(key, new_items[param_index])
			param_index += 1
	pass

func add_item(type, new_item):
	items[type] = new_item
	pass
