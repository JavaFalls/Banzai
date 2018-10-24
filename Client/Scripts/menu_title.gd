extends Node



func _ready():
	pass
	
func _process(delta):
	pass
	
func _input(event):
	if event is InputEventKey and event.is_pressed():
		get_tree().change_scene("res://Scenes/main_menu.tscn")

#func _process(delta):
#	pass
