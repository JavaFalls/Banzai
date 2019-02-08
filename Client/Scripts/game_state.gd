#400 X 225



extends Node
onready var player_position = [] # Player location
onready var player_mouse    = [] # Player mouse position
onready var player_vector   = [] # Player movement vector

onready var bot_position = [] # Bot location
onready var bot_mouse    = [] # Bot mouse position
onready var bot_vector   = [] # Bot movement vector 

onready var predicted_player_position = [] # Predicted player location
onready var predicted_player_mouse    = [] # Predicted player mouse position
onready var predicted_player_vector   = [] # Predicted player movement vector

onready var predicted_bot_position = [] # Predicted bot location
onready var predicted_bot_mouse    = [] # Predicted bot mouse position
onready var predicted_bot_vector   = [] # Predicted bot movement vector 

func get_battle_state():
	var game_state = []
	game_state.append(self.bot_x)
	game_state.append(self.bot_y)
	game_state.append(self.bot_x)
	game_state.append(self.bot_mouse_y)
	game_state.append(self.bot_vector_x)
	game_state.append(self.bot_vector_y)

	
	
	game_state.append(self.player_x)
	game_state.append(self.player_y)
	game_state.append(self.player_mouse_x)
	game_state.append(self.player_mouse_y)
	game_state.append(self.player_vector_x)
	game_state.append(self.player_vector_y)

	
	return game_state
	
func get_training_state():
	var game_state = []
	game_state.append(self.player_position)
	game_state.append(self.player_mouse)
	game_state.append(self.player_vector)

	game_state.append(self.bot_position)
	game_state.append(self.bot_mouse)
	game_state.append(self.bot_vector)

	return game_state
	
func set_bot_state(bot):
	self.bot_position = bot.get_position()
	bot_position[0]   = bot_position[0] / 400
	bot_position[1]   = bot_position[1] / 225
	self.bot_mouse    = bot.get_psuedo_mouse()
	bot_mouse[0]      = bot_mouse[0] / 400
	bot_mouse[1]      = bot_mouse[1] / 225
	self.bot_vector   = bot.get_trajectory()

	
func set_player_state(player):
	self.player_position = player.get_position()
	player_position[0]   = player_position[0] / 400
	player_position[1]   = player_position[1] / 225
	self.player_mouse    = player.get_psuedo_mouse()
	player_mouse[0]      = player_mouse[0] / 400
	player_mouse[1]      = player_mouse[1] / 225
	self.player_vector   = player.get_trajectory()

func set_predictions(predictions):
	predicted_bot_position[0] = predictions[0]
	predicted_bot_position[1] = predictions[1]
	predicted_bot_mouse[0]    = predictions[2]
	predicted_bot_mouse[1]    = predictions[3]
	predicted_bot_vector[0]   = predictions[4]
	predicted_bot_vector[1]   = predictions[5]
	
	predicted_player_position[0] = predictions[6]
	predicted_player_position[1] = predictions[7]
	predicted_player_mouse[0]    = predictions[8]
	predicted_player_mouse[1]    = predictions[9]
	predicted_player_vector[0]   = predictions[10]
	predicted_player_vector[1]   = predictions[11]
	
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

