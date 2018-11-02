var texture

var items = {
	"primary": null,
	"secondary": null,
	"ability": null
}

func _init():
	pass

func add_item(type, new_item):
	items[type] = new_item
	pass
