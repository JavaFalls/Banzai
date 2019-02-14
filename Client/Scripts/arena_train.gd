extends Node2D

# The Bot
var Bot = JSON.parse(head.DB.get_bot(head.bot_ID, true)).result["data"][0]

# The variables
var fighter1                             # Player or his AI bot
var fighter2                             # Opponent of player or AI bot
var start_pos1 = Vector2(200,48)         # Where the first fighter spawns
var start_pos2 = Vector2(200,175)        # Where the second fighter spawns

# The preloaded scenes
onready var player_scene = preload("res://Scenes/player.tscn")
onready var bot_scene    = preload("res://Scenes/bot.tscn")
onready var dummy_scene  = preload("res://Scenes/dummy.tscn")
onready var game_state   = get_node("game_state")

func _ready():
	# The player's bot or AI
	fighter1 = player_scene.instance()
	self.add_child(fighter1)
	fighter1.set_position(start_pos1)
	fighter1.set_name("fighter1")
	fighter1.set_is_player(true)

	fighter2 = bot_scene.instance()
	self.add_child(fighter2)
	fighter2.set_position(start_pos2)
	fighter2.set_name("fighter2")

	# Set the opponents for the respective fighters
	fighter1.set_opponent(fighter2)
	fighter2.set_opponent(fighter1)

# Called after game ends
func game_end():
	head.DB.update_bot(Bot["Bot_ID"])


func _process(delta):
	send_nn_state()

func send_nn_state():
	var output = []
	var path = PoolStringArray() 
	var predictions = []
	path.append('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/NeuralNetwork/client.py')
	print(game_state.get_training_state())
	path.append(game_state.get_training_state())
	OS.execute('python', path, true, output)
	print("OUT_PUT=================================================")
	print(output)
	output = output[0].split_floats(',', false)
	for x in output:
		x = round(x)
		x = int(x)
		predictions.append(x)
	print(predictions)
	return predictions