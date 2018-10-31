extends Node

onready var _macros = preload("res://Scripts/macros.gd")

onready var _manufacturor = get_node("VBoxContainer/HBoxContainer/manufacturor")
onready var _name = get_node("VBoxContainer/HBoxContainer/name")
onready var _code = get_node("VBoxContainer/HBoxContainer/code")

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
	["Java", "Hyper-actor", "!=ZZZ"],
	["Rosenburg", "TNT", "4megaton"],
	["ACME", "Burst-amator", "EZ-24/7"]
]

var full_name = {"M": "", "N": "", "C": ""}

func _ready():
	get_tree().get_root().connect("size_changed", self, "_resize")
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / _macros.NORMAL_WIDTH, size.y / _macros.NORMAL_HEIGHT)
	
	add_names()
	for n in full_name:
		_full_name.text += full_name[n] + " "
	pass
	
func _process(delta):
	pass
	
func _input(event):
	if event is InputEventKey and event.is_pressed():
		_ready_button.show()
		_manufacturor.show()
		_name.show()
		_code.show()
		_full_name.show()

func _resize():
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / _macros.NORMAL_WIDTH, size.y / _macros.NORMAL_HEIGHT)
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
		_full_name.text += full_name[n] + " "
	pass

func create_user():
	get_tree().change_scene("res://Scenes/main_menu.tscn")
	pass
