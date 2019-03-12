extends AudioStreamPlayer2D

onready var intro = preload("res://sounds/Background Sounds/Track 1 Intro.wav")
onready var loop1 = preload("res://sounds/Background Sounds/Track 1 - Loop 1 - Piano.wav")
onready var loop2 = preload("res://sounds/Background Sounds/Track 1 - Loop 2 - Organ.wav")
onready var loop3 = preload("res://sounds/Background Sounds/Track 1 - Loop 3 - Strings and Brass.wav")

func _ready():
	self.stream = intro
	self.play()
	
	
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
