extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

var sub_names = ["", "", ""]
onready var name_section = head.name_section

onready var names = get_node("names").get_children()

signal name_entered

func _ready():
	var initial_delay = 0.5
	var delay = initial_delay
	var name_pos = 0 # for sub_names
	var raw_JSON
	var name_dictionary
	var name_index

	if(!Menu_audio.menu_audio.playing):
		Menu_audio.menu_audio.play()

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
			button.get_node("PathFollow2D/Button").connect("mouse_entered", self, "button_hover")
			button.duration = 1.0
			button.delay = delay
			delay += 0.15
			button.slide()
			name_index += 1
		name_pos += 1
		name_section += 1
		delay = initial_delay * (name_pos + 0.5)
	
	yield(get_tree().create_timer(1.0), "timeout")
	head.play_stream(head.ui2, head.sounds.GAME_START)

func get_username():
	return sub_names[0] + " " + sub_names[1] + " " + sub_names[2]

var one_pass = false
func select_name(text, position):
	sub_names[position] = text
	names[position].text = text
	if not one_pass and sub_names[0] != "" and sub_names[1] != "" and sub_names[2] != "":
		var confirm = get_node("confirm_button")
		confirm.disabled = false
		confirm.get_child(0).scroll("r\ne\na\nd\ny")
		one_pass = true

func button_hover():
	head.play_stream(head.ui1, head.sounds.BUTTON_HOVER)

func start():
	head.play_stream(head.ui2, head.sounds.SCENE_CHANGE)
	emit_signal("name_entered")
