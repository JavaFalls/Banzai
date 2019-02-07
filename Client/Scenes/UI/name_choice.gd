extends Node

func _ready():
	var delay = 1.0
	for group in get_tree().get_nodes_in_group("buttons"):
		for button in group.get_children():
			button.delay = delay
			delay += 0.15
			button.slide()
		delay = 1.0
