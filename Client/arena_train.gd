extends Node2D

onready var player_scene = preload("res://player.tscn")
onready var bot_scene    = preload("res://bot.tscn")
var fighter1  
var fighter2
var start_pos1 = Vector2(320,320)
var start_pos2 = Vector2(320,160)

func _ready():
	#fighter1 = player_scene.instance()
	#self.add_child(fighter1)
	#fighter1.set_position(start_pos1)
	
	#fighter2 = bot_scene.instance()
	#self.add_child(fighter2)
	#fighter2.set_position(start_pos2)
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
