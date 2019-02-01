extends Node
onready var player_x = 01
onready var player_y = 0
onready var player_mouse_x = 02
onready var player_mouse_y = 0
onready var player_vector_x = 0
onready var player_vector_y = 03


onready var bot_x = 0
onready var bot_y = 05
onready var bot_mouse_x = 0
onready var bot_mouse_y = 0
onready var bot_vector_x = 06
onready var bot_vector_y = 0

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
	game_state.append(self.player_x)
	game_state.append(self.player_y)
	game_state.append(self.player_mouse_x)
	game_state.append(self.player_mouse_y)
	game_state.append(self.player_vector_x)
	game_state.append(self.player_vector_y)

	
	game_state.append(self.bot_x)
	game_state.append(self.bot_y)
	game_state.append(self.bot_x)
	game_state.append(self.bot_mouse_y)
	game_state.append(self.bot_vector_x)
	game_state.append(self.bot_vector_y)

	return game_state
	
func set_bot_state(bot):
	self.bot_x        = bot.get_x()
	self.bot_y        = bot.get_y()
	self.bot_mouse_x  = bot.get__mouse_x()
	self.bot_vector_x = bot.get_vector_x()

	
func set_player_state(player):
	self.player_x        = player.get_x()
	self.player_y        = player.get_y()
	self.player_mouse_x  = player.get_mouse_x()
	self.player_mouse_y  = player.get_mouse_y()
	self.player_vector_x = player.get_vector_x()
	self.player_vector_y = player.get_vector_y()

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

