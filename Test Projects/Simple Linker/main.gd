extends Node

var output = ['empty']

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	if Input.is_action_just_pressed('ui_accept'):
		OS.execute("C/", ['dir'], true, output)
		print(output, delta)
