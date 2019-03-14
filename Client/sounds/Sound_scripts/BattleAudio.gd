extends AudioStreamPlayer

onready var intro = preload("res://sounds/Background Sounds/Track 1 Intro.wav")
onready var loop1 = preload("res://sounds/Background Sounds/Track 1 - Loop 1 - Piano.wav")
onready var loop2 = preload("res://sounds/Background Sounds/Track 1 - Loop 2 - Organ.wav")

func _ready():
	self.set_bus('Arena')
	self.stream = intro
	self.play()
	
	pass
	
func loop_music():
	#while true:
	var random_loop = randi() % 3 + 1
	if random_loop == 1:
		self.stream = loop1
		self.play()
	elif random_loop == 2:
		self.stream = loop2
		self.play()

func _on_BattleAudio_finished():
	loop_music()
