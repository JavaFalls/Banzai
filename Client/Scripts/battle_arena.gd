extends Node2D

# The variables
var fighter1                       # Players fighter or AI
var fighter2                       # Opponent
var start_pos1 = Vector2(200,48)   # Where the first fighter spawns
var start_pos2 = Vector2(200,175)  # Where the second fighter spawns
var hit_points_difference          # how many points above the opponent is fighter1 (may be negative)

onready var player_scene = preload("res://Scenes/player.tscn")
onready var bot_scene    = preload("res://Scenes/bot.tscn")
onready var dummy_scene  = preload("res://Scenes/dummy.tscn")

# The signal that is emitted when a fighter's hit_points reach zero
signal game_end

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

# This function is called when one of the fighters hits zero hit_points
func post_game():
	head.battle_winner_calc(fighter1.get_hit_points(), fighter2.get_hit_points())
	get_tree().change_scene("res://Scenes/post_battle.tscn")
	fighter1.queue_free()
	fighter2.queue_free()
	
# This function is called to choose an opponent
# It returns the opponent bot's ID
func get_opponent(bot_id):
	var bot_rating = head.DB.get_bot(bot_id, false) # Current bot rating. Used as pivot point for matchmaking algorithm
	# get bot ID
	# get bot rating from DB
	# Collect at most 10 bots within a range of 5 up and 5 down
	# Randomly pick a bot ID and download that baby
	# Load the bot into the Neural Network and initialize the opponent
	# return