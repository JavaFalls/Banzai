#400 X 225



extends Node
onready var screen_x = 400
onready var screen_y = 225
onready var player_position = [] # Player location
onready var player_mouse    = [] # Player mouse position
onready var player_vector   = [] # Player movement vector
onready var player_psuedo_primary   = 0
onready var player_psuedo_secondary = 0
onready var player_psuedo_ability   = 0
onready var player_in_peril         = 0

onready var bot_position = [] # Bot location
onready var bot_mouse    = [] # Bot mouse position
onready var bot_vector   = [] # Bot movement vector 
onready var bot_psuedo_primary   = 0
onready var bot_psuedo_secondary = 0
onready var bot_psuedo_ability   = 0
onready var bot_in_peril         = 0

onready var predicted_player_position = Vector2() # Predicted player location
onready var predicted_player_mouse    = Vector2() # Predicted player mouse position
onready var predicted_player_vector   = Vector2() # Predicted player movement vector
onready var predicted_player_psuedo_primary   = 0
onready var predicted_player_psuedo_secondary = 0
onready var predicted_player_psuedo_ability   = 0
onready var predicted_player_in_peril         = 0

onready var predicted_bot_position = Vector2() # Predicted bot location
onready var predicted_bot_mouse    = Vector2() # Predicted bot mouse position
onready var predicted_bot_vector   = Vector2() # Predicted bot movement vector 
onready var predicted_bot_psuedo_primary   = 0
onready var predicted_bot_psuedo_secondary = 0
onready var predicted_bot_psuedo_ability   = 0
onready var predicted_bot_in_peril         = 0

# Sent to the NN to get predictions back
func get_battle_state():
	var game_state = []
	game_state.append(self.bot_position)
	game_state.append(self.bot_mouse)
	game_state.append(self.bot_vector)
	game_state.append(self.bot_psuedo_primary)
	game_state.append(self.bot_psuedo_secondary)
	game_state.append(self.bot_psuedo_ability)
	game_state.append(self.bot_in_peril)
	
	game_state.append(self.player_position)
	game_state.append(self.player_mouse)
	game_state.append(self.player_vector)
	game_state.append(self.player_psuedo_primary)
	game_state.append(self.player_psuedo_secondary)
	game_state.append(self.player_psuedo_ability)
	game_state.append(self.player_in_peril)
	
	return game_state
	
# Sent to the NN to teach it
func get_training_state():
	var game_state = []
	game_state.append(self.player_position)
	game_state.append(self.player_mouse)
	game_state.append(self.player_vector)
	game_state.append(self.player_psuedo_primary)
	game_state.append(self.player_psuedo_secondary)
	game_state.append(self.player_psuedo_ability)
	game_state.append(self.player_in_peril)

	game_state.append(self.bot_position)
	game_state.append(self.bot_mouse)
	game_state.append(self.bot_vector)
	game_state.append(self.bot_psuedo_primary)
	game_state.append(self.bot_psuedo_secondary)
	game_state.append(self.bot_psuedo_ability)
	game_state.append(self.bot_in_peril)

	return game_state
	
func set_bot_state(bot):
	self.bot_position = bot.get_position()
	bot_position[0]   = bot_position[0] / 400
	bot_position[1]   = bot_position[1] / 225
	self.bot_mouse    = bot.get_psuedo_mouse()
	bot_mouse[0]      = bot_mouse[0] / 400
	bot_mouse[1]      = bot_mouse[1] / 225
	self.bot_vector   = bot.get_trajectory()
	bot_psuedo_primary   = bot.psuedo_primary
	bot_psuedo_secondary = bot.psuedo_secondary
	bot_psuedo_ability   = bot.psuedo_ability
	bot_in_peril         = bot.in_peril
	

	
func set_player_state(player):
	self.player_position = player.get_position()
	player_position[0]   = player_position[0] / 400
	player_position[1]   = player_position[1] / 225
	self.player_mouse    = player.get_psuedo_mouse()
	player_mouse[0]      = player_mouse[0] / 400
	player_mouse[1]      = player_mouse[1] / 225
	self.player_vector   = player.get_trajectory()
	player_psuedo_primary   = player.psuedo_primary
	player_psuedo_secondary = player.psuedo_secondary
	player_psuedo_ability   = player.psuedo_ability
	player_in_peril         = player.in_peril
	

func set_predictions(predictions):
	if predictions:
		predicted_bot_position      = Vector2(predictions[0] * screen_x, predictions[1] * screen_y)
		predicted_bot_mouse         = Vector2(predictions[2] * screen_x, predictions[3])
		predicted_bot_vector        = Vector2(predictions[4], predictions[5])
		predicted_bot_psuedo_primary   = predictions[6]
		predicted_bot_psuedo_secondary = predictions[7]
		predicted_bot_psuedo_ability   = predictions[8]
		predicted_bot_in_peril         = predictions[9]
		
		predicted_player_position      = Vector2(predictions[10] * screen_x, predictions[11] * screen_y)
		predicted_player_mouse         = Vector2(predictions[12] * screen_x, predictions[13] * screen_y)
		predicted_player_vector        = Vector2(predictions[14], predictions[15])
		predicted_player_psuedo_primary   = predictions[16]
		predicted_player_psuedo_secondary = predictions[17]
		predicted_player_psuedo_ability   = predictions[18]
		predicted_player_in_peril         = predictions[19]
		
func get_predictions():
	var pred = []
	pred.append(predicted_player_position)
	pred.append(predicted_player_mouse)
	pred.append(predicted_player_vector)
	pred.append(predicted_player_psuedo_primary)
	pred.append(predicted_player_psuedo_secondary)
	pred.append(predicted_player_psuedo_ability)
	pred.append(predicted_player_in_peril)

	pred.append(predicted_bot_position)
	pred.append(predicted_bot_mouse)
	pred.append(predicted_bot_vector)
	pred.append(predicted_bot_psuedo_primary)
	pred.append(predicted_bot_psuedo_secondary)
	pred.append(predicted_bot_psuedo_ability)
	pred.append(predicted_bot_in_peril)
	return pred

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

