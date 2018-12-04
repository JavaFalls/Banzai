extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

func _ready():
	pass
	
func _input(event):
	if event is InputEventKey and event.is_pressed():
		create_user()

func create_user():
	get_tree().change_scene("res://Scenes/name_choice.tscn")
	pass
