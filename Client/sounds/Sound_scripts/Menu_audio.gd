extends Node

var menu_audio
onready var loop = preload("res://sounds/Background Sounds/Track 3.wav")

func _ready():
	add_child(AudioStreamPlayer.new())
	menu_audio = get_child(0)
	menu_audio.set_bus('Menu')
	menu_audio.stream = loop
	# menu_audio.play()
	pass