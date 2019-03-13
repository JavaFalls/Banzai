extends Node

func _ready():
	randomize()
	get_tree().change_scene("res://Scenes/menu_title.tscn")

#func _process(delta):
#	pass
