extends Node2D

# The Player and Bot
onready var player_data = JSON.parse(
	head.DB.get_bot(head.player_bot_ID, "File_%s.h5" % str(head.player_bot_ID))).result["data"][0]
onready var bot_data = JSON.parse(
					   head.DB.get_bot(head.bot_ID,
									   "File_%s.h5" % str(head.bot_ID))).result["data"][0]
#onready var bot_data = JSON.parse(head.DB.get_bot(1,"File_%s.h5" % str(1))).result["data"][0]# for seth and jonathan
#onready var player_data = JSON.parse(head.DB.get_bot(1,"File_%s.h5" % str(1))).result["data"][0]# for seth and jonathan
onready var nn_results = preload("res://Scenes/popups/nn_results.tscn")

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
	fighter1.set_pause_mode(Node.PAUSE_MODE_STOP)
	fighter1.set_position(start_pos1)
	fighter1.set_name("fighter1")
	fighter1.set_weapons(weapon_creator.create_weapon(player_data["primary_weapon"]), weapon_creator.create_weapon(player_data["secondary_weapon"]), weapon_creator.create_weapon(player_data["utility"]))
	get_node("UI_container/fighter1_cooldowns").init(player_data["primary_weapon"], fighter1.primary_weapon,
													 player_data["secondary_weapon"], fighter1.secondary_weapon,
													 player_data["utility"], fighter1.ability)
	fighter1.is_player = 1
	fighter1.get_node("animation_bot").load_colors_from_DB(head.player_bot_ID)


	fighter2 = bot_scene.instance()
	self.add_child(fighter2)
	fighter2.set_pause_mode(Node.PAUSE_MODE_STOP)
	fighter2.set_position(start_pos2)
	fighter2.set_name("fighter2")
	fighter2.set_weapons(weapon_creator.create_weapon(bot_data["primary_weapon"]), weapon_creator.create_weapon(bot_data["secondary_weapon"]), weapon_creator.create_weapon(bot_data["utility"]))
	get_node("UI_container/fighter2_cooldowns").init(bot_data["primary_weapon"], fighter2.primary_weapon,
													 bot_data["secondary_weapon"], fighter2.secondary_weapon,
													 bot_data["utility"], fighter2.ability)
	fighter2.get_node("animation_bot").load_colors_from_DB(head.bot_ID)

#	 Set the opponents for the respective fighters
	fighter1.set_opponent(fighter2)
	fighter2.set_opponent(fighter1)
	
	t.set_wait_time(.01)
	t.set_one_shot(true)
	self.add_child(t)
	t.set_pause_mode(Node.PAUSE_MODE_STOP)
	t.start()
	
	$timeout/Timer.connect("timeout", self, "timeout")

# Called after game ends
func game_end():
	popup = arena_end_popup.instance()
	self.add_child(popup)
	popup.init("Training Has Ended", "Yes", "No", self, "keep_data", self, "drop_data", "Would you like your robot to learn from this session?")


func _process(delta):
	if t.is_stopped():
		send_nn_state()
		t.start()

func _input(event):
	if Input.is_action_just_pressed("exit_arena"):
		save_bot()
		print("bot saved", head.bot_ID)
		if not get_tree().is_paused():
			get_tree().set_pause(true)
			$exit.visible = true

func send_nn_state():
	game_state.set_opponent_state(fighter1)
	game_state.set_bot_state(fighter2)
	var output = []
	var message
	message = '{ "Message Type": "Train", "Message": %s }' % str(game_state.get_training_state())
	head.Client.send_request(message)
	output = head.Client.get_response()
	output = int(output)
	if(output != null):
		game_state.set_predictions(output)

func timeout():
	get_tree().paused = true
	yield($timeout, "resumed")
	if not $exit.visible:
		get_tree().paused = false

# Popup Functions
func keep_data():
	get_tree().paused = false
	save_bot()
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

func _on_confirm_pressed():
	$exit.visible = false
	var results_popup
	if nn_results.can_instance():
		results_popup = nn_results.instance(PackedScene.GEN_EDIT_STATE_DISABLED)
	$popup_layer.add_child(results_popup)
	results_popup.connect("go_back", self, "exit_results", [results_popup])
	results_popup.connect("save", self, "exit_arena")

func _on_back_pressed():
	get_tree().set_pause(false)
	$exit.visible = false

# Load Bot for Training
func load_bot():
	var output = []
	var message
	message = '{ "Message Type":"Load", "Game Mode": "Train", "File Name": "File_%s.h5" }' % str(head.bot_ID)
	head.Client.send_request(message)
	output = head.Client.get_response()
	head.dir.remove(ProjectSettings.globalize_path('res://NeuralNetwork/models/File_%s.h5' % str(head.bot_ID)))
	return output == 'true'

# Save Bot after training
func save_bot():
	var message = '{ "Message Type": "Save", "File Name": "File_%s.h5"}' % str(head.bot_ID)
	head.Client.send_request(message)
	var output = head.Client.get_response()
	head.DB.update_model_by_bot_id(head.bot_ID, 'File_%s.h5' % str(head.bot_ID))
	head.dir.remove(ProjectSettings.globalize_path('res://NeuralNetwork/models/File_%s.h5' % str(head.bot_ID)))

func exit_results(popup):
	popup.queue_free()
	get_tree().set_pause(false)

func exit_arena():
	get_tree().set_pause(false)
	get_tree().change_scene("res://Scenes/main_menu.tscn")
