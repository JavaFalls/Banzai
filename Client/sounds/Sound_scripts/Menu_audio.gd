extends Node

onready var loop = preload("res://sounds/Background Sounds/Track 1 - Loop 3 - Strings and Brass.wav")
onready var menu_audio = AudioStreamPlayer.new()

func _ready():
	menu_audio.stream = loop
	menu_audio.play()
	
	pass