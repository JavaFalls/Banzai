extends Node

# Get head singleton
#onready var head = get_tree().get_root().get_node("/root/head")

var sub_names = ["", "", ""]

onready var names = get_node("names").get_children()

signal name_entered

func _ready():
	var delay = 1.0
	var name_pos = 0 # for sub_names
	var name_section = 1 # Which name section to grab names from
	var raw_JSON
	var name_dictionary
	var name_index
	for group in get_tree().get_nodes_in_group("buttons"):
		name_index = 0
		raw_JSON = head.DB.get_name_parts(name_section)
		if (raw_JSON != ""):
			name_dictionary = JSON.parse(raw_JSON).result["data"]
		else:
			name_dictionary = Dictionary()
		for button in group.get_children():
			if (name_index < name_dictionary.size()):
				button.text = name_dictionary[name_index]["name"]
			button.get_node("PathFollow2D/Button").connect("pressed", self, "select_name", [button.text, name_pos])
			button.delay = delay
			delay += 0.15
			button.slide()
			name_index += 1
		delay = 1.0
		name_pos += 1
		name_section += 1

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
	emit_signal("name_entered")
	head.username = get_username()
	head.create_user() # create_user() must be run after head.username is set
	get_tree().change_scene("res://Scenes/main_menu.tscn")
