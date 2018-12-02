extends Node2D

onready var player_scene = preload("res://Scenes/player.tscn")
onready var bot_scene    = preload("res://Scenes/bot.tscn")
onready var dummy_scene  = preload("res://Scenes/dummy.tscn")

signal game_end

var fighter1                              # Players fighter or AI
var fighter2                              # Opponent
var start_pos1 = Vector2(200,48)         # Where the first fighter spawns
var start_pos2 = Vector2(200,175)         # Where the second fighter spawns
var hit_points_difference                  # how many points above the opponent is fighter1 (may be negative)

func _ready():
    #add code here to choose who fights (player or AIs)
	fighter1 = dummy_scene.instance()
	self.add_child(fighter1)
	fighter1.set_position(start_pos1)
	fighter1.set_name("fighter1")

	#fighter2 = bot_scene.instance()
	fighter2 = dummy_scene.instance()
	self.add_child(fighter2)
	fighter2.set_position(start_pos2)
	#fighter2.attack_primary = false
	fighter2.set_name("fighter2")

	# tell fighters who theyre opponent is
	fighter1.set_opponent(fighter2)
	fighter2.set_opponent(fighter1)
	
	# Connect signal for post game
	connect("game_end", self, "post_game")
	fighter1.connect("game_end", self, "post_game")
	fighter2.connect("game_end", self, "post_game")

func post_game():
	hit_points_difference = fighter1.get_hit_points() - fighter2.get_hit_points() 
	get_tree().change_scene("res://Scenes/arena_battle.tscn")
	fighter1.queue_free()
	fighter2.queue_free()
	pass
	
#func _process(delta):
#	pass
	

