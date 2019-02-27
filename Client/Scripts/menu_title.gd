extends Node

# Get head singleton
#onready var head = get_tree().get_root().get_node("/root/head")
onready var intro_text = get_node("Container/VBoxContainer/intro_text")

onready var alpha = 0
onready var alpha_modifier = get_node("alpha_timer").wait_time

func _ready():
	pass

func _process(delta):
	pass
	
func _input(event):
	if event is InputEventKey and event.is_pressed():
		create_user()

func create_user():
	get_tree().change_scene("res://Scenes/name_choice.tscn")
	pass


func _on_alpha_timer_timeout():
	alpha += alpha_modifier
	if (alpha <= 0.0 || alpha >= 1.0):
		alpha_modifier = -alpha_modifier
	intro_text.modulate = Color(1,1,1,alpha)
