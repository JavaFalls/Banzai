extends Node

onready var bot = $animation_bot

var t = 0.0

func _ready():
	pass

func _process(delta):
	t += delta
	if t > 0.5:
		if bot.is_facing_right():
			bot.face_left()
		else:
			bot.face_right()
		t = 0.0

func _on_back_button_pressed():
	get_tree().change_scene("res://Scenes/main_menu.tscn")

func _on_back_button_mouse_entered():
	$back_button/Label.modulate = Color("#ffffff")

func _on_back_button_mouse_exited():
	$back_button/Label.modulate = Color("#aaaaaa")
