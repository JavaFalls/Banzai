extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

onready var _manufacturor = get_node("VBoxContainer/HBoxContainer/MarginContainer/manufacturor")
onready var _name = get_node("VBoxContainer/HBoxContainer/MarginContainer2/name")
onready var _code = get_node("VBoxContainer/HBoxContainer/MarginContainer3/code")

onready var _ready_button = get_node("VBoxContainer/ready")
onready var _full_name = get_node("VBoxContainer/full_name")

onready var _background = get_node("MarginContainer/background")

var names = [
	["manufacturor", "name", "code"],
	["manufacturor", "name", "code"],
	["manufacturor", "name", "code"],
	["manufacturor", "name", "code"],
	["manufacturor", "name", "code"],
	["manufacturor", "name", "code"],
	["Java", "Hyper-actor", "sleep=0"],
	["Rosenburg", "TNT", "40megaton"],
	["ACME", "Burst-amator", "EZ-24/7"]
]

var full_name = {"M": "", "N": "", "C": ""}

func _ready():
	get_tree().get_root().connect("size_changed", self, "_resize")
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / head.NORMAL_WIDTH, size.y / head.NORMAL_HEIGHT)
	
	add_names()
	for n in full_name:
		_full_name.text += full_name[n] + " "
	pass
	
func _process(delta):
	pass
	
func _input(event):
	if event is InputEventKey and event.is_pressed():
		_ready_button.show()
		_ready_button.get_node("Tween").interpolate_property(
			_ready_button, "rect_scale:y", 0, 1,
			0.6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
		)
		_ready_button.get_node("Tween").start()
		
		_manufacturor.show()
		_manufacturor.get_node("Tween").interpolate_property(
			_manufacturor, "rect_scale:y", 0, 1,
			2, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
		)
		_manufacturor.get_node("Tween").start()
		
		_name.show()
		_name.get_node("Tween").interpolate_property(
			_name, "rect_scale:y", 0, 1,
			4, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
		)
		_name.get_node("Tween").start()
		
		_code.show()
		_code.get_node("Tween").interpolate_property(
			_code, "rect_scale:y", 0, 1,
			6, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
		)
		_code.get_node("Tween").start()
		
		_full_name.show()
	pass

func _resize():
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / head.NORMAL_WIDTH, size.y / head.NORMAL_HEIGHT)
	pass

func add_names():
	for n in names:
		_manufacturor.add_item(n[0])
		_name.add_item(n[1])
		_code.add_item(n[2])
	pass

func name_changed(index, list):
	match (list):
		"M":
			full_name[list] = _manufacturor.get_item_text(index)
		"N":
			full_name[list] = _name.get_item_text(index)
		"C":
			full_name[list] = _code.get_item_text(index)
	_full_name.text = ""
	for n in full_name:
		_full_name.text += " " + full_name[n] + " "
	if full_name['M'] != "" and full_name["N"] != "" and full_name["C"] != "":
		_ready_button.disabled = false
	pass

func create_user():
	get_tree().change_scene("res://Scenes/main_menu.tscn")
	pass
