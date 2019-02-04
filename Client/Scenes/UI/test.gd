extends Node

func _ready():
	var delay = 1
	for button in get_children():
		button.delay = delay
		delay += 0.2
		button.slide()
