extends AudioStreamPlayer2D

onready var intro = preload("res://sounds/Background Sounds/Track 1 Intro.wav")
onready var loop1 = preload("res://sounds/Background Sounds/Track 1 - Loop 1 - Piano.wav")
onready var loop2 = preload("res://sounds/Background Sounds/Track 1 - Loop 2 - Organ.wav")
onready var loop3 = preload("res://sounds/Background Sounds/Track 1 - Loop 3 - Strings and Brass.wav")

func _ready():
	self.stream = intro
	self.play()
	
	pass
	
func loop_music():
	while true:
		var random_loop = randi() % 3 + 1
		if random_loop == 1:
			self.stream = loop1
			self.play()
		elif random_loop == 2:
			self.stream = loop2
			self.play()
		elif random_loop == 3:
			self.stream = loop3
			self.play()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_ArenaAudio_finished():
	loop_music()
