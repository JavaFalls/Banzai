extends Node2D

# The Bot
#onready var Bot = JSON.parse(head.DB.get_bot(head.bot_ID)).result["data"][0]

# The variables
var fighter1                             # Player or his AI bot
var fighter2                             # Opponent of player or AI bot
var start_pos1 = Vector2(200,73)         # Where the first fighter spawns
var start_pos2 = Vector2(200,175)        # Where the second fighter spawns

var popup                                # Popup scene used when battle is over

# The preloaded scenes
onready var player_scene    = preload("res://Scenes/player.tscn")
onready var bot_scene       = preload("res://Scenes/bot.tscn")
onready var dummy_scene     = preload("res://Scenes/dummy.tscn")
onready var arena_end_popup = preload("res://Scenes/popups/arena_end_popup.tscn")
onready var game_state      = get_node("game_state")
onready var t               = Timer.new()

func _ready():
#	 The player's bot or AI
	fighter1 = player_scene.instance()
	self.add_child(fighter1)
	fighter1.set_position(start_pos1)
	fighter1.set_name("fighter1")
	fighter1.is_player = 1
	fighter1.get_node("animation_bot").load_colors_from_DB(head.bot_ID)


	fighter2 = bot_scene.instance()
	self.add_child(fighter2)
	fighter2.set_position(start_pos2)
	fighter2.set_name("fighter2")
	fighter2.get_node("animation_bot").load_colors_from_DB(head.bot_ID)

#	 Set the opponents for the respective fighters
	fighter1.set_opponent(fighter2)
	fighter2.set_opponent(fighter1)
	
	t.set_wait_time(.3)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()

# Called after game ends
func game_end():
	popup = arena_end_popup.instance()
	self.add_child(popup)
	popup.init("Training Has Ended", "Yes", "No", self, "keep_data", self, "drop_data", "Would you like your robot to learn from this session?")


func _process(delta):
	if t.is_stopped():
		send_nn_state()
		t.start()

func send_nn_state():
	var output = []
	var message
	message = '{ "Message Type": "Request", "Message": %s }' % str(game_state.get_training_state())
	head.Client.send_request(message)
	output = head.Client.get_response()
	output = int(output)
	if(output):
		game_state.set_predictions(output)

# Popup Functions
func keep_data():
	get_tree().paused = false
	#head.DB.update_model(head.model_ID, "idk_what_the_filename_for_the_model_would_be")
	popup.free()
	final_popup()
func drop_data():
	get_tree().paused = false
	popup.free()
	final_popup()
func final_popup():
	popup = arena_end_popup.instance()
	self.add_child(popup)
	popup.init("Training Has Ended", "Contiune", "Main Menu", self, "contiune_training", self, "main_menu", "Keep training or return to the main menu?")
func contiune_training():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/Load_training.tscn")
func main_menu():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/main_menu.tscn")
