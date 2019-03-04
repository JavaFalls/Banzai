extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")
onready var intro_text = get_node("Container/VBoxContainer/intro_text")

onready var alpha = 0
onready var alpha_modifier = get_node("alpha_timer").wait_time

onready var name_choice_screen = preload("res://Scenes/name_choice.tscn").instance(PackedScene.GEN_EDIT_STATE_DISABLED)

func _ready():
	pass

func _process(delta):
	pass
	
func _input(event):
	if event is InputEventKey and event.is_pressed():
		create_user()

func create_user():
	name_choice_screen.get_node("confirm_button/Label").text = "p\nl\na\ny\ne\nr"
	add_child(name_choice_screen)
	yield(name_choice_screen, "name_entered")
	head.username = name_choice_screen.get_username()
	head.create_user() # create_user() must be run after head.username is set
	get_tree().change_scene("res://Scenes/main_menu.tscn")


func _on_alpha_timer_timeout():
	alpha += alpha_modifier
	if (alpha <= 0.0 || alpha >= 1.0):
		alpha_modifier = -alpha_modifier
	intro_text.modulate = Color(1,1,1,alpha)
