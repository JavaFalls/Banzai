extends Node

var sub_names = ["", "", ""]

onready var names = get_node("names").get_children()

func _ready():
	var delay = 1.0
	var name_pos = 0 # for sub_names
	for group in get_tree().get_nodes_in_group("buttons"):
		for button in group.get_children():
			button.get_node("PathFollow2D/Button").connect("pressed", self, "select_name", [button.text, name_pos])
			button.delay = delay
			delay += 0.15
			button.slide()
		delay = 1.0
		name_pos += 1

func get_username():
	return sub_names[0] + " " + sub_names[1] + " " + sub_names[2]

var one_pass = false
func select_name(text, position):
	sub_names[position] = text
	names[position].text = text
	if not one_pass and sub_names[0] != "" and sub_names[1] != "" and sub_names[2] != "":
		var confirm = get_node("confirm_button")
		confirm.disabled = false
		confirm.get_child(0).get_child(0).play("ready")
		one_pass = true

func start():
	head.username = get_username()
	head.create_user() # create_user() must be run after head.username is set
	get_tree().change_scene("res://Scenes/main_menu.tscn")
