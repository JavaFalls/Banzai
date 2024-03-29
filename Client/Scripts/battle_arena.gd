# This scene is meant to be the training area and battle area for player and ai mechs

extends Node2D

#Constants
const UPPER_LIMIT = 1500
const LOWER_LIMIT = -1500

# The variables
var fighter1                       # Player's fighter or AI
var fighter2                       # Opponent
var start_pos1 = Vector2(120,130)         # Where the first fighter spawns
var start_pos2 = Vector2(280,130)        # Where the second fighter spawns
var health                         # The starting health of a mech for use with HUD

var popup                          # Popup scene used when battle is over

var options_visible = false

# The signal that is emitted when a fighter's hit_points reach zero
signal post_game

onready var player_scene    = preload("res://Scenes/player.tscn")
onready var bot_scene       = preload("res://Scenes/bot.tscn")
onready var dummy_scene     = preload("res://Scenes/dummy.tscn")
onready var arena_end_popup = preload("res://Scenes/popups/arena_end_popup.tscn")
onready var game_state      = get_node("game_state")
onready var f               = File.new()
onready var t               = Timer.new()
onready var game_time       = get_node("game_time")
onready var max_game_time   = 1.5 * 60
onready var timer_label     = get_node("Panel/Label")
onready var plr_health_bar  = self.get_node("UI_container/healthbar/health1")
onready var opp_health_bar  = self.get_node("UI_container/healthbar/health2")

# Get Opponent
onready var opponent_bot_ID = get_opponent(head.bot_ID)
# Find the "loading" scene so that we can notify it of our progress
onready var scene_loading = get_node("/root/loading")

func _ready():
	get_tree().paused = true
	var bot_data
	var opponent_data
	scene_loading.set_progress_bar(10)
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	
	# Make sure that we actually found an oppoent to fight
	if opponent_bot_ID == null:
		# No Opponent found! Display a popup and abort further processing
		scene_loading.set_progress_bar(100)
		popup = arena_end_popup.instance()
		add_child(popup) # Must add the popup as a child BEFORE calling init()
		popup.init("No bots found to do battle against.",
				   "Search",
				   "Main Menu",
				   self,
				   "fight_again",
				   self,
				   "main_menu",
				   "Search again for an opponent, or return to the main menu?")
		return
	else:
		# Get bot information, and load bot models from the database
		bot_data = JSON.parse(head.DB.get_bot(head.bot_ID, "File_%s.h5" % str(head.bot_ID))).result["data"][0]
		scene_loading.set_progress_bar(30)
		yield(get_tree(),"idle_frame")
		yield(get_tree(),"idle_frame")
		opponent_data = JSON.parse(head.DB.get_bot(opponent_bot_ID, "File_%s.h5" % str(opponent_bot_ID))).result["data"][0]
		scene_loading.set_progress_bar(50)
		yield(get_tree(),"idle_frame")
		yield(get_tree(),"idle_frame")
	
	
	#f.open('res://NeuralNetwork/gamestates', 3)
	
	# Load bots into the Neural Network
	load_bot()
	
	# Initialize the bots
	fighter1 = bot_scene.instance()
	self.add_child(fighter1)
	fighter1.set_position(start_pos1)
	fighter1.set_name("fighter1")
	# Get bot weapons from DB---------------------------------
	fighter1.set_weapons(weapon_creator.create_weapon(bot_data["primary_weapon"]), weapon_creator.create_weapon(bot_data["secondary_weapon"]), weapon_creator.create_weapon(bot_data["utility"]))
	get_node("UI_container/fighter1_cooldowns").fighter_num = 1
	get_node("UI_container/fighter1_cooldowns").init(bot_data["primary_weapon"], fighter1.primary_weapon,
													 bot_data["secondary_weapon"], fighter1.secondary_weapon,
													 bot_data["utility"], fighter1.ability)
	get_node("UI_container/fighter1_name").text = bot_data["name"]
	fighter1.get_node("animation_bot").load_colors_from_DB(head.bot_ID)
	#---------------------------------------------------------
	fighter1.is_player = 1
	scene_loading.set_progress_bar(95)
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	
	fighter2 = bot_scene.instance()
	self.add_child(fighter2)
	fighter2.set_position(start_pos2)
	fighter2.set_name("fighter2")
	# Get bot weapons from DB---------------------------------
	fighter2.set_weapons(weapon_creator.create_weapon(opponent_data["primary_weapon"]), weapon_creator.create_weapon(opponent_data["secondary_weapon"]), weapon_creator.create_weapon(opponent_data["utility"]))
	get_node("UI_container/fighter2_cooldowns").fighter_num = 2
	get_node("UI_container/fighter2_cooldowns").init(opponent_data["primary_weapon"], fighter2.primary_weapon,
													 opponent_data["secondary_weapon"], fighter2.secondary_weapon,
													 opponent_data["utility"], fighter2.ability)
	get_node("UI_container/fighter2_name").text = opponent_data["name"]
	fighter2.get_node("animation_bot").load_colors_from_DB(opponent_bot_ID)
	#---------------------------------------------------------
	
	# tell fighters who theyre opponent is
	fighter1.set_opponent(fighter2)
	fighter2.set_opponent(fighter1)
	
	# Connect signal for post game
	fighter1.connect("game_end", self, "post_game")
	fighter2.connect("game_end", self, "post_game")
	scene_loading.set_progress_bar(100)
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	
	health = fighter1.get_hit_points()
	
	t.set_wait_time(.01)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	game_time.set_wait_time(max_game_time)
	game_time.start()
	get_tree().paused = false
	
	$exit_layer/nn_options/back_button.hide()
	$exit_layer/nn_options/Label.hide()
	$exit_layer/nn_options/Tween.connect("tween_completed", self, "exit_options")
	if typeof(bot_data["model_ID_FK"]) == TYPE_REAL:
		$exit_layer/nn_options.model_ID = int(bot_data["model_ID_FK"])
	else:
		$exit_layer/nn_options.model_ID = bot_data["model_ID_FK"]
	$exit_layer/nn_options.load_options_from_DB()

func _process(delta):
	plr_health_bar.set_scale(Vector2(get_node("fighter1").get_hit_points()*11.6211/health,1))
	opp_health_bar.set_scale(Vector2(get_node("fighter2").get_hit_points()*11.6211/health,1))

	if opp_health_bar.get_scale().x < .25*11.6211:
		opp_health_bar.set_modulate(Color(1,0,0,1))
	elif opp_health_bar.get_scale().x < .66*11.6211:
		opp_health_bar.set_modulate(Color(1,1,0,1))
	else:
		plr_health_bar.set_modulate(Color(0,1,0,1))
	if plr_health_bar.get_scale().x < .25*11.6211:
		plr_health_bar.set_modulate(Color(1,0,0,1))
	elif plr_health_bar.get_scale().x < .66*11.6211:
		plr_health_bar.set_modulate(Color(1,1,0,1))
	else:
		plr_health_bar.set_modulate(Color(0,1,0,1))

	
	if t.is_stopped():
		send_nn_state(1)
		# a number mod two to decide wich one gets set when
		#send_nn_state(2) # pass bots number.
	
		# Print time to display
		timer_label.text = str(int(game_time.get_time_left()))
	
		t.start()

func _input(event):
	if event is InputEventKey:
		if event.is_action("exit_arena") and not get_tree().is_paused():
			get_tree().paused = true
			$exit_layer/exit.visible = true
		
		if event.scancode == KEY_O and not event.is_echo():
			var tween = $exit_layer/nn_options/Tween
			var options = $exit_layer/nn_options
			var options_alpha = 0.68
			var remnant = (options_alpha-options.modulate.a)/options_alpha
			
			if not options_visible:
				tween.remove_all()
				tween.interpolate_property(options, "modulate:a", options.modulate.a, options_alpha, 1.0*remnant, Tween.TRANS_LINEAR, Tween.EASE_IN)
				options.show()
				tween.start()
				options_visible = true
			else:
				tween.remove_all()
				tween.interpolate_property(options, "modulate:a", options.modulate.a, 0.0, 1.0*abs(options_alpha-remnant), Tween.TRANS_LINEAR, Tween.EASE_OUT)
				tween.start()
				options_visible = false

func exit_options(object, node_path):
	if not options_visible:
		$exit_layer/nn_options.exit()

# This function is called when one of the fighters hits zero hit_points
func post_game():
	# Last update to bots health
	self.get_node("UI_container/healthbar").get_node("health1").set_scale(Vector2(get_node("fighter1").get_hit_points()*11.6211/health,1))
	self.get_node("UI_container/healthbar").get_node("health2").set_scale(Vector2(get_node("fighter2").get_hit_points()*11.6211/health,1))
	self.set_process(false) # We never process again (scene must be reloaded if another battle is desired)
	# Notify that battle is over
	self.emit_signal("post_game")
	var popup_message
	# Modify bot rankings
	head.battle_winner_calc(fighter1.get_hit_points(), fighter2.get_hit_points())
	var bot_data = JSON.parse(head.DB.get_bot(head.bot_ID)).result["data"][0]
	var opponent_data = JSON.parse(head.DB.get_bot(opponent_bot_ID)).result["data"][0]
	head.DB.update_bot(head.bot_ID, [DBConnector.NULL_INT, DBConnector.NULL_INT, bot_data["ranking"] + head.score_change, DBConnector.NULL_INT, DBConnector.NULL_INT, DBConnector.NULL_INT, DBConnector.NULL_COLOR, DBConnector.NULL_COLOR, DBConnector.NULL_COLOR, ""], "")
	head.DB.update_bot(opponent_bot_ID, [DBConnector.NULL_INT, DBConnector.NULL_INT, opponent_data["ranking"] + (head.score_change * -0.5), DBConnector.NULL_INT, DBConnector.NULL_INT, DBConnector.NULL_INT, DBConnector.NULL_COLOR, DBConnector.NULL_COLOR, DBConnector.NULL_COLOR, ""], "")
	# Remove destroyed bots from the arena:
	if fighter1.hit_points <= 0:
		fighter1.queue_free()
		fighter1 = null
	else:
		fighter1.set_process(false)
		fighter1.set_physics_process(false)
	if fighter2.hit_points <= 0:
		fighter2.queue_free()
		fighter2 = null
	else:
		fighter2.set_process(false)
		fighter2.set_physics_process(false)
	# Prepare message:
	if head.battle_won:
		popup_message = "Your robot is victorious, ranking +" + String(head.score_change)
	else:
		popup_message = "Your robot has been defeated, ranking " + String(head.score_change)
	# Display battle over popup:
	popup = arena_end_popup.instance()
	self.add_child(popup) # Must add the popup as a child BEFORE calling init()

	popup.init("Battle Has Ended", "Again?", "Main Menu", self, "fight_again", self, "main_menu", popup_message)


# This function is called to choose an opponent
# It returns the opponent bot's ID.
# If no opponent is found, null is returned
func get_opponent(bot_id):
	var opponent = null
	var rank_width = 0
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

func send_nn_state(bot_number):
	game_state.set_opponent_state(fighter1)
	game_state.set_bot_state(fighter2)
	var output = []
	var message
	message = '{ "Message Type": "Battle", "Message": %s }' % str(game_state.get_battle_state())
	head.Client.send_request(message)
	output = head.Client.get_response()
#	output = Vector2(1,1) # standin so that the nnserver doesn't have to be called.
	print(output, "this is the output")

	if output != "File Deleted" and output != "successful": # remove this once deleting the bots doesn't take so long
		output = output.replacen("(", ",")
		output = output.split_floats(",", 0)
		for x in output:
			x = int(x)
		game_state.set_predictions(output[0])
		game_state.set_opponent_predictions(output[1])
	#game_state.set_opponent_predictions(output)
	return

# Popup Functions
func fight_again():
	get_tree().paused = false
	head.load_scene("res://Scenes/battle_arena.tscn")
	self.queue_free()
func main_menu():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/main_menu.tscn")
	#self.queue_free()

# Load Bot for Battle
func load_bot():
	var message
	var output = []
	# Load Opponent bot into Neural Network
	message = '{ "Message Type":"Load", "Game Mode": "Battle", "File Name": "File_%s.h5", "Opponent?": "Yes" }' % str(opponent_bot_ID)
	head.Client.send_request(message)
	output.append(head.Client.get_response())
	message = '{ "Message Type": "Delete File", "File Path": "File_%s.h5" }' % str(opponent_bot_ID)
	head.Client.send_request(message)
	output.append(head.Client.get_response())
	scene_loading.set_progress_bar(70)
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	
	# Load Player bot into Neural Network
	message = '{ "Message Type":"Load", "Game Mode": "Battle", "File Name": "File_%s.h5", "Opponent?": "No" }'  % str(head.bot_ID)
	head.Client.send_request(message)
	output.append(head.Client.get_response())
	message = '{ "Message Type": "Delete File", "File Path": "File_%s.h5" }' % str(head.bot_ID)
	head.Client.send_request(message)
	output.append(head.Client.get_response())
	scene_loading.set_progress_bar(90)
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")

func game_time_end():
	if fighter1.hit_points > fighter2.hit_points:
		fighter2.hit_points = 0
		post_game()
	else:
		if fighter1.hit_points == fighter2.hit_points:
			game_time.start()
			timer_label.add_color_override("font_color", Color(1,0,0,1))
			return
		else:
			fighter1.hit_points = 0
			post_game()
		
func exit_early():
	head.battle_winner_calc(0, 500)
	var bot_data = JSON.parse(head.DB.get_bot(head.bot_ID)).result["data"][0]
	head.DB.update_bot(head.bot_ID, [DBConnector.NULL_INT, DBConnector.NULL_INT, bot_data["ranking"] + head.score_change, DBConnector.NULL_INT, DBConnector.NULL_INT, DBConnector.NULL_INT, DBConnector.NULL_COLOR, DBConnector.NULL_COLOR, DBConnector.NULL_COLOR, ""], "")
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/main_menu.tscn")

func dont_exit_early():
	get_tree().paused = false
	$exit_layer/exit.visible = false
