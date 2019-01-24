extends Node2D

onready var player_scene = preload("res://Scenes/player.tscn")
onready var bot_scene    = preload("res://Scenes/bot.tscn")
onready var dummy_scene  = preload("res://Scenes/dummy.tscn")

var fighter1                              # Players fighter or AI
var fighter2                              # Opponent
var start_pos1 = Vector2(200,48)         # Where the first fighter spawns
var start_pos2 = Vector2(200,175)         # Where the second fighter spawns

func _ready():
	#add code here to choose who fights (player or AIs)
	fighter1 = player_scene.instance()
	self.add_child(fighter1)
	fighter1.set_position(start_pos1)
	fighter1.set_name("fighter1")
	fighter1.set_is_player(true)
	
	fighter2 = bot_scene.instance()
	fighter2 = bot_scene.instance()
	self.add_child(fighter2)
	fighter2.set_position(start_pos2)
	fighter2.set_name("fighter2")

	fighter1.set_opponent(fighter2)
	fighter2.set_opponent(fighter1)
	
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass