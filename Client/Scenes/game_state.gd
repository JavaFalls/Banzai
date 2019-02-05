extends Node
onready var player_position = [] # Player location
onready var player_mouse    = [] # Player mouse position
onready var player_vector   = [] # Player movement vector

onready var bot_position = [] # Bot location
onready var bot_mouse    = [] # Bot mouse position
onready var bot_vector   = [] # Bot movement vector 

onready var predicted_player_x = 01
onready var predicted_player_y = 0
onready var predicted_player_mouse_x = 02
onready var predicted_player_mouse_y = 0
onready var predicted_player_vector_x = 0
onready var predicted_player_vector_y = 03


onready var predicted_bot_x = 0
onready var predicted_bot_y = 05
onready var predicted_bot_mouse_x = 0
onready var predicted_bot_mouse_y = 0
onready var predicted_bot_vector_x = 06
onready var predicted_bot_vector_y = 0


# class member variables go here, for example:
# var a = 2
# var b = "textvar"
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
	bot_position[0] = int(bot_position[0])
	bot_position[1] = int(bot_position[1])
	self.bot_mouse    = bot.get_psuedo_mouse()
	self.bot_vector   = bot.get_trajectory()

	
func set_player_state(player):
	self.player_position = player.get_position()
	player_position[0] = int(player_position[0])
	player_position[1] = int(player_position[1])
	self.player_mouse    = player.get_global_mouse_position()
	self.player_vector   = player.get_trajectory()

func set_predictions(predictions):
	predicted_player_x = 01
	predicted_player_y = 0
	predicted_player_mouse_x = 02
	predicted_player_mouse_y = 0
	predicted_player_vector_x = 0
	predicted_player_vector_y = 03
	
	predicted_bot_x = 0
	predicted_bot_y = 05
	predicted_bot_mouse_x = 0
	predicted_bot_mouse_y = 0
	predicted_bot_vector_x = 06
	predicted_bot_vector_y = 0

	
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

