extends Control

func _ready():
	$back_button.connect("pressed", self, "exit")

func exit():
	for option in get_tree().get_nodes_in_group("ui_option"):
		option.get_value()
	self.visible = false
