extends Node2D

# The Player and Bot
onready var player_data = JSON.parse(head.DB.get_bot(head.player_bot_ID)).result["data"][0]
onready var bot_data = JSON.parse(
					   head.DB.get_bot(head.bot_ID,
									   "File_%s.h5" % str(head.bot_ID))).result["data"][0]
#onready var bot_data = JSON.parse(head.DB.get_bot(1,"File_%s.h5" % str(1))).result["data"][0]# for seth and jonathan
#onready var player_data = JSON.parse(head.DB.get_bot(1,"File_%s.h5" % str(1))).result["data"][0]# for seth and jonathan

# The variables
var fighter1                             # Player or his AI bot
var fighter2                             # Opponent of player or AI bot
var start_pos1 = Vector2(120,130)         # Where the first fighter spawns
var start_pos2 = Vector2(280,130)        # Where the second fighter spawns

var popup                                # Popup scene used when battle is over

# The preloaded scenes
onready var player_scene    = preload("res://Scenes/player.tscn")
onready var bot_scene       = preload("res://Scenes/bot.tscn")
onready var dummy_scene     = preload("res://Scenes/dummy.tscn")
onready var arena_end_popup = preload("res://Scenes/popups/arena_end_popup.tscn")
onready var game_state      = get_node("game_state")
onready var t               = Timer.new()

func _ready():
	
#	load the player's ai model into nnserver
	load_bot()
	
#	 The player's bot or AI
	fighter1 = player_scene.instance()
	self.add_child(fighter1)
	fighter1.set_pause_mode(Node.PAUSE_MODE_STOP)
	fighter1.set_position(start_pos1)
	fighter1.set_name("fighter1")
	fighter1.set_weapons(weapon_creator.create_weapon(player_data["primary_weapon"]), weapon_creator.create_weapon(player_data["secondary_weapon"]), weapon_creator.create_weapon(player_data["utility"]))
	get_node("UI_container/fighter1_cooldowns").fighter_num = 1
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
	get_node("UI_container/fighter2_cooldowns").fighter_num = 2
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
	
	get_node("/root/loading").set_progress_bar(100)
	$timeout/Timer.connect("timeout", self, "timeout")

# Called after game ends
func game_end():
	var message = '{ "Message Type": "Graph Results"}'
	head.Client.send_request(message)
	popup = arena_end_popup.instance()
	self.add_child(popup)
	popup.init("Training Has Ended", "Yes", "No", self, "keep_data", self, "drop_data", "Would you like your robot to learn from this session?")


func _process(delta):
	if t.is_stopped():
		send_nn_state()
		t.start()

func _input(event):
	if Input.is_action_just_pressed("exit_arena"):
#		head.save_bot()
#		exit_arena()
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
	head.load_scene("res://Scenes/arena_train.tscn")
func main_menu():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/main_menu.tscn")

func _on_confirm_pressed():
	head.save_bot()
	get_tree().set_pause(false)
	get_tree().change_scene("res://Scenes/main_menu.tscn")

func _on_back_pressed():
	get_tree().set_pause(false)
	$exit.visible = false

# Load Bot for Training
func load_bot():
	var output = []
	var message
	# Load reward settings
	# - Get rewards from the DB
	var rewards_dictionary = JSON.parse(head.DB.get_model_rewards_by_bot_id(head.bot_ID)).result["data"][0]
	# - Convert dictionary to a regular array
	var rewards_array = []
	rewards_array.append(rewards_dictionary["reward_accuracy"])
	rewards_array.append(rewards_dictionary["reward_avoidence"])
	rewards_array.append(rewards_dictionary["reward_approach"])
	rewards_array.append(rewards_dictionary["reward_flee"])
	rewards_array.append(rewards_dictionary["reward_damage_dealt"])
	rewards_array.append(rewards_dictionary["reward_damage_received"])
	rewards_array.append(rewards_dictionary["reward_health_received"])
	rewards_array.append(rewards_dictionary["reward_melee_damage"])
	
	# - Send the rewards to the Neural Network
	message = '{ "Message Type":"Set Rewards", "Rewards": "%s" }' % str(rewards_array)
	head.Client.send_request(message)
	output = head.Client.get_response()
	
	# Load Player bot into Neural Network
	message = '{ "Message Type":"Load", "Game Mode": "Battle", "File Name": "File_%s.h5", "Opponent?": "No" }'  % str(head.bot_ID)
	head.Client.send_request(message)
	output = head.Client.get_response()
	message = '{ "Message Type": "Delete File", "File Path": "File_%s.h5" }' % str(head.bot_ID)
	head.Client.send_request(message)
	output = head.Client.get_response()
