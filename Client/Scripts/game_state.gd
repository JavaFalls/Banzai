#400 X 225

extends Node

onready var screen_x = 400
onready var screen_y = 225

onready var bot_position      = Vector2()
onready var bot_aim_angle     = 0
onready var bot_health        = 0
onready var bot_in_peril      = 0
onready var player_angle      = 0
onready var opponent_distance = 0
onready var bot_angle         = 0
onready var player_in_peril   = 0
onready var player_health     = 0
onready var player_aim_angle  = 0
onready var player_position   = Vector2()

onready var relative_vector = Vector2()

onready var predicted_action               = 0

#its position, opponent distance, opponent angle (radians but normalized), aim vector, in peril, b health p health

#onready var player_position = [] # Player location
onready var player_mouse    = [] # Player mouse position
onready var player_vector   = [] # Player movement vector
onready var player_psuedo_primary   = 0
onready var player_psuedo_secondary = 0
onready var player_psuedo_ability   = 0
#onready var player_in_peril         = 0
onready var player_hit_points       = 0
onready var player_reward           = 0

#onready var bot_position = [] # Bot location
onready var bot_mouse    = [] # Bot mouse position
onready var bot_vector   = [] # Bot movement vector 
onready var bot_psuedo_primary   = 0
onready var bot_psuedo_secondary = 0
onready var bot_psuedo_ability   = 0
#onready var bot_in_peril         = 0
onready var bot_hit_points       = 0
onready var bot_reward           = 0

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

	relative_vector = bot_position - player_position
	opponent_distance = sqrt(pow(relative_vector.x,2) + pow(relative_vector.y,2))
	bot_angle = (atan2(relative_vector.x,relative_vector.y)-PI)/(-2*PI)
	relative_vector *= -1
	player_angle = (atan2(relative_vector.x, relative_vector.y)-PI)/(-2*PI)
	
	game_state.append(self.bot_position)
	game_state.append(self.bot_aim_angle)
	game_state.append(self.bot_health)
	game_state.append(self.bot_in_peril)
	game_state.append(self.player_angle) # calc this
	game_state.append(self.opponent_distance) # calculate this
	game_state.append(self.bot_angle) # calc this
	game_state.append(self.player_in_peril)
	game_state.append(self.player_health)
	game_state.append(self.player_aim_angle)
	game_state.append(self.player_position)
	return game_state 

	
# Sent to the NN to teach it
#func get_training_state():
#	var game_state = []
#	game_state.append(self.player_position)
#	game_state.append(self.player_mouse)
#	game_state.append(self.player_vector)
#	game_state.append(self.player_psuedo_primary)
#	game_state.append(self.player_psuedo_secondary)
#	game_state.append(self.player_psuedo_ability)
#	game_state.append(self.player_in_peril)
#
#	game_state.append(self.bot_position)
#	game_state.append(self.bot_mouse)
#	game_state.append(self.bot_vector)
#	game_state.append(self.bot_psuedo_primary)
#	game_state.append(self.bot_psuedo_secondary)
#	game_state.append(self.bot_psuedo_ability)
#	game_state.append(self.bot_in_peril)
#
#	return game_state
	
func set_bot_state(bot):
#	self.bot_position = bot.get_position()
#	bot_position[0]   = bot_position[0] / 400
#	bot_position[1]   = bot_position[1] / 225
#	self.bot_mouse    = bot.get_psuedo_mouse()
#	bot_mouse[0]      = bot_mouse[0] / 400
#	bot_mouse[1]      = bot_mouse[1] / 225
#	self.bot_vector   = (bot.get_trajectory()+Vector2(1,1))/Vector2(2,2)
#	bot_psuedo_primary   = bot.psuedo_primary
#	bot_psuedo_secondary = bot.psuedo_secondary
#	bot_psuedo_ability   = bot.psuedo_ability
#	bot_in_peril         = bot.in_peril
#	bot_reward           = bot.psuedo_primary*200
#	bot_hit_points       = bot.hit_points
	self.bot_position = bot.get_position()
	self.bot_position[0]   = bot_position[0] / 400
	self.bot_position[1]   = bot_position[1] / 225
	self.bot_aim_angle     = (bot.aim_angle-PI)/(-2*PI) #divide in order to normalize
	self.bot_health        = bot.hit_points
	self.bot_in_peril      = bot.in_peril 
	
	
#	self.bot_position = bot.get_position()
#	bot_position[0]   = randf()
#	bot_position[1]   = randf()
#	self.bot_mouse    = bot.get_psuedo_mouse()
#	bot_mouse[0]      = randf()
#	bot_mouse[1]      = randf()
#	self.bot_vector   = Vector2(randf(),randf())
#	bot_psuedo_primary   = randf()
#	bot_psuedo_secondary = randf()
#	bot_psuedo_ability   = randf()
#	bot_in_peril         = randf()
	
func set_player_state(player):
#	self.player_position = player.get_position()
#	player_position[0]   = player_position[0] / 400
#	player_position[1]   = player_position[1] / 225
#	self.player_mouse    = player.get_psuedo_mouse()
#	player_mouse[0]      = player_mouse[0] / 400
#	player_mouse[1]      = player_mouse[1] / 225
#	self.player_vector   = (player.get_trajectory()+Vector2(1,1))/Vector2(2,2)
#	player_psuedo_primary   = player.psuedo_primary
#	player_psuedo_secondary = player.psuedo_secondary
#	player_psuedo_ability   = player.psuedo_ability
#	player_in_peril         = player.in_peril
#	player_reward           = player.hit_points - player_hit_points
#	player_hit_points       = player.hit_points
	self.player_position = player.get_position()
	self.player_position[0]   = player_position[0] / 400
	self.player_position[1]   = player_position[1] / 225
	self.player_aim_angle     = (player.aim_angle-PI)/(-2*PI) # divide in order to normalize
	self.player_health        = player.hit_points
	self.player_in_peril      = player.in_peril
	
#	self.player_position = player.get_position()
#	player_position[0]   = randf()
#	player_position[1]   = randf()
#	self.player_mouse    = player.get_psuedo_mouse()
#	player_mouse[0]      = randf()
#	player_mouse[1]      = randf()
#	self.player_vector   = Vector2(randf(),randf())
#	player_psuedo_primary   = randf()
#	player_psuedo_secondary = randf()
#	player_psuedo_ability   = randf()
#	player_in_peril         = randf()


func set_predictions(predictions):
	predicted_action = predictions[0]

	if predicted_action  == 0:
		predicted_bot_vector = Vector2(0,0)
	elif predicted_action == 1:
		predicted_bot_vector = Vector2(1,0)
	elif predicted_action == 2:
		predicted_bot_vector = Vector2(-1,0)
	elif predicted_action == 3:
		predicted_bot_vector = Vector2(0,1)
	elif predicted_action == 4:
		predicted_bot_vector = Vector2(0,-1)
	if predicted_action == 5:
		predicted_bot_psuedo_primary = 1
	else:
		predicted_bot_psuedo_primary = 0
		
func get_predictions():
	var pred = []
	pred.append((predicted_player_position))
	pred.append((predicted_player_mouse))
	pred.append((predicted_player_vector))
	pred.append((predicted_player_psuedo_primary))
	pred.append((predicted_player_psuedo_secondary))
	pred.append((predicted_player_psuedo_ability))
	pred.append((predicted_player_in_peril))

	pred.append((predicted_bot_position))
	pred.append((predicted_bot_mouse))
	pred.append((predicted_bot_vector))
	pred.append((predicted_bot_psuedo_primary))
	pred.append((predicted_bot_psuedo_secondary))
	pred.append((predicted_bot_psuedo_ability))
	pred.append((predicted_bot_in_peril))
	return pred
