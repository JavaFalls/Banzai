# This scene is meant to be the training area and battle area for player and ai mechs

extends Node2D

#Constants
const UPPER_LIMIT = 1500
const LOWER_LIMIT = 0

# The variables
var fighter1                       # Player's fighter or AI
var fighter2                       # Opponent
var start_pos1 = Vector2(200,73)   # Where the first fighter spawns
var start_pos2 = Vector2(200,175)  # Where the second fighter spawns
var health                         # The starting health of a mech for use with HUD

var popup                          # Popup scene used when battle is over

onready var player_scene    = preload("res://Scenes/player.tscn")
onready var bot_scene       = preload("res://Scenes/bot.tscn")
onready var dummy_scene     = preload("res://Scenes/dummy.tscn")
onready var arena_end_popup = preload("res://Scenes/popups/arena_end_popup.tscn")
onready var game_state      = get_node("game_state")
onready var f               = File.new()
onready var t               = Timer.new()

# The signal that is emitted when a fighter's hit_points reach zero
signal game_end

func _ready():
	f.open('res://NeuralNetwork/gamestates', 3)
    # Call get opponent here
#	var opponent_bot_ID = get_opponent(head.bot_ID)
	fighter1 = bot_scene.instance() #player_scene.instance()
	self.add_child(fighter1)
	fighter1.set_position(start_pos1)
	fighter1.set_name("fighter1")
	fighter1.is_player = 1
#	fighter1.get_node("animation_bot").load_colors_from_DB(head.bot_ID)

	fighter2 = bot_scene.instance() # fighter2 = dummy_scene.instance()
	self.add_child(fighter2)
	fighter2.set_position(start_pos2)
	#fighter2.attack_primary = false
	fighter2.set_name("fighter2")
#	fighter2.get_node("animation_bot").load_colors_from_DB(opponent_bot_ID)

	# tell fighters who theyre opponent is
	fighter1.set_opponent(fighter2)
	fighter2.set_opponent(fighter1)

	# Connect signal for post game
	connect("game_end", self, "post_game")
	fighter1.connect("game_end", self, "post_game")
	fighter2.connect("game_end", self, "post_game")

	health = fighter1.get_hit_points()

	t.set_wait_time(.3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()

func _physics_process(delta):
	self.get_node("healthbar").get_node("health1").set_scale(Vector2(get_node("fighter1").get_hit_points()*11.6211/health,1))
	self.get_node("healthbar").get_node("health2").set_scale(Vector2(get_node("fighter2").get_hit_points()*11.6211/health,1))
	if t.is_stopped():
		send_nn_state(1) # pass number of bots. 
		t.start()
		print("===================battle arena send nn response=========================")
#		print(game_state.get_predictions())

# This function is called when one of the fighters hits zero hit_points
func post_game():
	var popup_message
	head.battle_winner_calc(fighter1.get_hit_points(), fighter2.get_hit_points())
	if head.battle_won:
		fighter2.queue_free()
		popup_message = "Your robot is victorious, ranking + " + String(head.score_change)
	else:
		fighter1.queue_free()
		popup_message = "Your robot has been defeated, ranking - " + String(head.score_change)
	popup = arena_end_popup.instance()
	self.add_child(popup)
	popup.init("Battle Has Ended", "Again?", "Main Menu", self, "fight_again", self, "main_menu", popup_message)


# This function is called to choose an opponent
# It returns the opponent bot's ID.
# If no opponent is found, null is returned
func get_opponent(bot_id):
	var opponent = null
	var rank_width = 0
	#var bot_data = JSON.parse(head.DB.get_bot(bot_id)).result["data"][0] # Get all bot data from Database
	var bot_data = JSON.parse(head.DB.get_bot(bot_id)).result["data"][0] # Get all bot data from Database
	var lowest_rank = bot_data["ranking"]
	var upper_rank  = bot_data["ranking"]

	# Search for opponents as long as the rank range is not exited
	while (opponent == null) && ((lowest_rank != LOWER_LIMIT) || (upper_rank != UPPER_LIMIT)):
		rank_width += 5
		lowest_rank = (bot_data["ranking"] - rank_width)
		upper_rank  = (bot_data["ranking"] + rank_width)

		if lowest_rank < LOWER_LIMIT:
			lowest_rank = LOWER_LIMIT
		if upper_rank > UPPER_LIMIT:
			upper_rank = UPPER_LIMIT

		# Get possible opponents from the Database
		var opponent_list = JSON.parse(head.DB.get_bot_range(bot_id, lowest_rank, upper_rank)).result["data"]

		if opponent_list.size() > 0:
			randomize()
			opponent = opponent_list[randi()%opponent_list.size()-1]["bot_ID_PK"]
		else:
			opponent = null
	return opponent

func send_nn_state(number_of_bots):
	var output = []
	var message = '{ "Message Type": "Request", "Message": %s }' % str(game_state.get_battle_state())
	head.Client.send_request(message)
#	print("OUT_PUT=================================================")
#	print(output)
	output = head.Client.get_response()
	output = output[0].split_floats(',', false)
	game_state.set_predictions(output)
	if number_of_bots > 1:
		message = '{ "Message Type": "Request", "Message": %s }' % str(game_state.get_training_state())
		output = head.Client.get_response()
		output = output[0].split_floats(',', false)
		game_state.set_opponent_predictions(output)
	return output

# Popup Functions
func fight_again():
	get_tree().paused = false
	head.load_scene("res://Scenes/battle_arena.tscn")
func main_menu():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/main_menu.tscn")
