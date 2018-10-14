extends Node

func _ready():
	pass

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene("res://Scenes/menu_title.tscn")
	pass

func _on_customize_button_pressed():
	get_tree().change_scene("res://Scenes/build.tscn")
	pass

func _on_train_button_pressed():
	get_tree().change_scene("res://Scenes/arena_train.tscn")
	pass

func _on_fight_button_pressed():
	get_tree().change_scene("res://Scenes/arena_battle.tscn")
	pass
