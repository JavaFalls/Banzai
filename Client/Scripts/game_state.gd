#400 X 225

extends Node

onready var screen_x = 400
onready var screen_y = 225

onready var bot_position      = Vector2()
onready var bot_aim_angle     = 0
onready var bot_health        = 0
onready var bot_in_peril      = 0
onready var opponent_angle      = 0
onready var opponent_distance = 0
onready var bot_angle         = 0
onready var opponent_in_peril   = 0
onready var opponent_health     = 0
onready var opponent_aim_angle  = 0
onready var opponent_position   = Vector2()

onready var relative_vector = Vector2()

onready var predicted_action               = 0

#its position, opponent distance, opponent angle (radians but normalized), aim vector, in peril, b health p health

#onready var player_position = [] # Player location
onready var opponent_mouse    = [] # Player mouse position
onready var opponent_vector   = [] # Player movement vector
onready var opponent_psuedo_primary   = 0
onready var opponent_psuedo_secondary = 0
onready var opponent_psuedo_ability   = 0
#onready var player_in_peril         = 0
onready var opponent_hit_points       = 0
onready var opponent_reward           = 0

#onready var bot_position = [] # Bot location
onready var bot_mouse    = [] # Bot mouse position
onready var bot_vector   = [] # Bot movement vector
onready var bot_psuedo_primary   = 0
onready var bot_psuedo_secondary = 0
onready var bot_psuedo_ability   = 0
#onready var bot_in_peril         = 0
onready var bot_hit_points       = 0
onready var bot_reward           = 0

onready var predicted_opponent_position = Vector2() # Predicted player location
onready var predicted_opponent_mouse    = Vector2() # Predicted player mouse position
onready var predicted_opponent_vector   = Vector2() # Predicted player movement vector
onready var predicted_opponent_psuedo_primary   = 0
onready var predicted_opponent_psuedo_secondary = 0
onready var predicted_opponent_psuedo_ability   = 0
onready var predicted_opponent_in_peril         = 0

onready var predicted_bot_position = Vector2() # Predicted bot location
onready var predicted_bot_mouse    = Vector2() # Predicted bot mouse position
onready var predicted_bot_vector   = Vector2() # Predicted bot movement vector
onready var predicted_bot_psuedo_primary   = 0
onready var predicted_bot_psuedo_secondary = 0
onready var predicted_bot_psuedo_ability   = 0
onready var predicted_bot_in_peril         = 0

onready var predicted_bot_aim_left  = 0
onready var predicted_bot_aim_right = 0

onready var predicted_opponent_aim_left  = 0
onready var predicted_opponent_aim_right = 0



# Sent to the NN to get predictions back
func get_battle_state():
	var game_state = []

	relative_vector = bot_position - opponent_position
	opponent_distance = sqrt(pow(relative_vector.x,2) + pow(relative_vector.y,2))
	bot_angle = (atan2(relative_vector.x,relative_vector.y)-PI)/(-2*PI)
	relative_vector *= -1
	opponent_angle = (atan2(relative_vector.x, relative_vector.y)-PI)/(-2*PI)

	game_state.append(self.bot_position)
	game_state.append(self.bot_aim_angle)
	game_state.append(self.bot_health)
	game_state.append(self.bot_in_peril)
	game_state.append(self.opponent_angle) # calc this
	game_state.append(self.opponent_distance) # calculate this
	game_state.append(self.bot_angle) # calc this
	game_state.append(self.opponent_in_peril)
	game_state.append(self.opponent_health)
	game_state.append(self.opponent_aim_angle)
	game_state.append(self.opponent_position)
	return game_state


func get_training_state():
	var game_state = []
	for x in self.get_battle_state():
		game_state.push_front(x)
	return game_state

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

func set_opponent_state(opponent):
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
	self.opponent_position = opponent.get_position()
	self.opponent_position[0]   = opponent_position[0] / 400
	self.opponent_position[1]   = opponent_position[1] / 225
	self.opponent_aim_angle     = (opponent.aim_angle-PI)/(-2*PI) # divide in order to normalize # this probably doesnt work ?
	self.opponent_health        = opponent.hit_points
	self.opponent_in_peril      = opponent.in_peril

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
	predicted_action = predictions
#	print("set predictions")
#	print(predicted_action)
#	print(predictions[0])
#	print("end set Predictions print")

	predicted_bot_vector = Vector2(0,0)
	predicted_bot_psuedo_primary   = 0
	predicted_bot_psuedo_secondary = 0
	predicted_bot_psuedo_ability   = 0
	predicted_bot_aim_right        = 0
	predicted_bot_aim_left         = 0

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
	elif predicted_action  == 5:
		predicted_bot_vector = Vector2(1,1)
	elif predicted_action == 6:
		predicted_bot_vector = Vector2(1,-1)
	elif predicted_action == 7:
		predicted_bot_vector = Vector2(-1,1)
	elif predicted_action == 8:
		predicted_bot_vector = Vector2(-1,-1)
	elif predicted_action == 9:
		predicted_bot_psuedo_primary = 1
	elif predicted_action == 10:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_psuedo_primary = 1
	elif predicted_action == 11:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_psuedo_primary = 1
	elif predicted_action == 12:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_psuedo_primary = 1
	elif predicted_action == 13:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_psuedo_primary = 1
	elif predicted_action  == 14:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_psuedo_primary = 1
	elif predicted_action == 15:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_psuedo_primary = 1
	elif predicted_action == 16:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_psuedo_primary = 1
	elif predicted_action == 17:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_psuedo_primary = 1
	elif predicted_action  == 18:
		predicted_bot_psuedo_secondary = 1
	elif predicted_action == 19:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_psuedo_secondary = 1
	elif predicted_action == 20:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_psuedo_secondary = 1
	elif predicted_action == 21:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_psuedo_secondary = 1
	elif predicted_action == 22:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_psuedo_secondary = 1
	elif predicted_action  == 23:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_psuedo_secondary = 1
	elif predicted_action == 24:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_psuedo_secondary = 1
	elif predicted_action == 25:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_psuedo_secondary = 1
	elif predicted_action == 26:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_psuedo_secondary = 1
	elif predicted_action  == 27:
		predicted_bot_psuedo_ability = 1
	elif predicted_action == 28:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_psuedo_ability = 1
	elif predicted_action == 29:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_psuedo_ability = 1
	elif predicted_action == 30:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_psuedo_ability = 1
	elif predicted_action == 31:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_psuedo_ability = 1
	elif predicted_action  == 32:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_psuedo_ability = 1
	elif predicted_action == 33:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_psuedo_ability = 1
	elif predicted_action == 34:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_psuedo_ability = 1
	elif predicted_action == 35:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_psuedo_ability = 1

	elif predicted_action  == 36:
		predicted_bot_aim_right = 1
	elif predicted_action == 37:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_aim_right = 1
	elif predicted_action == 38:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_aim_right = 1
	elif predicted_action == 39:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_aim_right = 1
	elif predicted_action == 40:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_aim_right = 1
	elif predicted_action  == 41:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_aim_right = 1
	elif predicted_action == 42:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_aim_right = 1
	elif predicted_action == 43:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_aim_right = 1
	elif predicted_action == 44:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_aim_right = 1
	elif predicted_action == 45:
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 46:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 47:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 48:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 49:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_right = 1
	elif predicted_action  == 50:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 51:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 52:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 53:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_right = 1
	elif predicted_action  == 54:
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 55:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 56:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 57:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 58:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_right = 1
	elif predicted_action  == 59:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 60:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 61:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 62:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_right = 1
	elif predicted_action  == 63:
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 64:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 65:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 66:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 67:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_right = 1
	elif predicted_action  == 68:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 69:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 70:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_right = 1
	elif predicted_action == 71:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_right = 1

	elif predicted_action  == 72:
		predicted_bot_aim_left = 1
	elif predicted_action == 73:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_aim_left = 1
	elif predicted_action == 74:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_aim_left = 1
	elif predicted_action == 75:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_aim_left = 1
	elif predicted_action == 76:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_aim_left = 1
	elif predicted_action  == 77:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_aim_left = 1
	elif predicted_action ==78:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_aim_left = 1
	elif predicted_action == 79:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_aim_left = 1
	elif predicted_action == 80:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_aim_left = 1
	elif predicted_action == 81:
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 82:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 83:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 84:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 85:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_left = 1
	elif predicted_action  == 86:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 87:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 88:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 89:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_psuedo_primary = 1
		predicted_bot_aim_left = 1
	elif predicted_action  == 90:
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 91:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 92:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 93:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 94:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_left = 1
	elif predicted_action  == 95:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 96:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 97:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 98:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_psuedo_secondary = 1
		predicted_bot_aim_left = 1
	elif predicted_action  == 99:
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 100:
		predicted_bot_vector = Vector2(1,0)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 101:
		predicted_bot_vector = Vector2(-1,0)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 102:
		predicted_bot_vector = Vector2(0,1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 103:
		predicted_bot_vector = Vector2(0,-1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_left = 1
	elif predicted_action  == 104:
		predicted_bot_vector = Vector2(1,1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 105:
		predicted_bot_vector = Vector2(1,-1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 106:
		predicted_bot_vector = Vector2(-1,1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_left = 1
	elif predicted_action == 107:
		predicted_bot_vector = Vector2(-1,-1)
		predicted_bot_psuedo_ability = 1
		predicted_bot_aim_left = 1

func set_opponent_predictions(predictions):
	var predicted_action = predictions

	var predicted_opponent_vector = Vector2(0,0)
	var predicted_opponent_psuedo_primary   = 0
	var predicted_opponent_psuedo_secondary = 0
	var predicted_opponent_psuedo_ability   = 0
	var predicted_opponent_aim_right        = 0
	var predicted_opponent_aim_left         = 0

	if predicted_action  == 0:
		predicted_opponent_vector = Vector2(0,0)
	elif predicted_action == 1:
		predicted_opponent_vector = Vector2(1,0)
	elif predicted_action == 2:
		predicted_opponent_vector = Vector2(-1,0)
	elif predicted_action == 3:
		predicted_opponent_vector = Vector2(0,1)
	elif predicted_action == 4:
		predicted_opponent_vector = Vector2(0,-1)
	elif predicted_action  == 5:
		predicted_opponent_vector = Vector2(1,1)
	elif predicted_action == 6:
		predicted_opponent_vector = Vector2(1,-1)
	elif predicted_action == 7:
		predicted_opponent_vector = Vector2(-1,1)
	elif predicted_action == 8:
		predicted_opponent_vector = Vector2(-1,-1)
	elif predicted_action == 9:
		predicted_opponent_psuedo_primary = 1
	elif predicted_action == 10:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_psuedo_primary = 1
	elif predicted_action == 11:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_psuedo_primary = 1
	elif predicted_action == 12:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_psuedo_primary = 1
	elif predicted_action == 13:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_psuedo_primary = 1
	elif predicted_action  == 14:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_psuedo_primary = 1
	elif predicted_action == 15:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_psuedo_primary = 1
	elif predicted_action == 16:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_psuedo_primary = 1
	elif predicted_action == 17:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_psuedo_primary = 1
	elif predicted_action  == 18:
		predicted_opponent_psuedo_secondary = 1
	elif predicted_action == 19:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_psuedo_secondary = 1
	elif predicted_action == 20:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_psuedo_secondary = 1
	elif predicted_action == 21:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_psuedo_secondary = 1
	elif predicted_action == 22:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_psuedo_secondary = 1
	elif predicted_action  == 23:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_psuedo_secondary = 1
	elif predicted_action == 24:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_psuedo_secondary = 1
	elif predicted_action == 25:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_psuedo_secondary = 1
	elif predicted_action == 26:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_psuedo_secondary = 1
	elif predicted_action  == 27:
		predicted_opponent_psuedo_ability = 1
	elif predicted_action == 28:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_psuedo_ability = 1
	elif predicted_action == 29:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_psuedo_ability = 1
	elif predicted_action == 30:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_psuedo_ability = 1
	elif predicted_action == 31:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_psuedo_ability = 1
	elif predicted_action  == 32:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_psuedo_ability = 1
	elif predicted_action == 33:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_psuedo_ability = 1
	elif predicted_action == 34:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_psuedo_ability = 1
	elif predicted_action == 35:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_psuedo_ability = 1

	elif predicted_action  == 36:
		predicted_opponent_aim_right = 1
	elif predicted_action == 37:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_aim_right = 1
	elif predicted_action == 38:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_aim_right = 1
	elif predicted_action == 39:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_aim_right = 1
	elif predicted_action == 40:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_aim_right = 1
	elif predicted_action  == 41:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_aim_right = 1
	elif predicted_action == 42:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_aim_right = 1
	elif predicted_action == 43:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_aim_right = 1
	elif predicted_action == 44:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_aim_right = 1
	elif predicted_action == 45:
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 46:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 47:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 48:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 49:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action  == 50:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 51:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 52:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 53:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action  == 54:
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 55:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 56:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 57:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 58:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action  == 59:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 60:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 61:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 62:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_right = 1
	elif predicted_action  == 63:
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 64:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 65:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 66:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 67:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_right = 1
	elif predicted_action  == 68:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 69:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 70:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_right = 1
	elif predicted_action == 71:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_right = 1

	elif predicted_action  == 72:
		predicted_opponent_aim_left = 1
	elif predicted_action == 73:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_aim_left = 1
	elif predicted_action == 74:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_aim_left = 1
	elif predicted_action == 75:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_aim_left = 1
	elif predicted_action == 76:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_aim_left = 1
	elif predicted_action  == 77:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_aim_left = 1
	elif predicted_action ==78:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_aim_left = 1
	elif predicted_action == 79:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_aim_left = 1
	elif predicted_action == 80:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_aim_left = 1
	elif predicted_action == 81:
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 82:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 83:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 84:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 85:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action  == 86:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 87:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 88:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 89:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_psuedo_primary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action  == 90:
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 91:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 92:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 93:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 94:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action  == 95:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 96:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 97:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 98:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_psuedo_secondary = 1
		predicted_opponent_aim_left = 1
	elif predicted_action  == 99:
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 100:
		predicted_opponent_vector = Vector2(1,0)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 101:
		predicted_opponent_vector = Vector2(-1,0)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 102:
		predicted_opponent_vector = Vector2(0,1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 103:
		predicted_opponent_vector = Vector2(0,-1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_left = 1
	elif predicted_action  == 104:
		predicted_opponent_vector = Vector2(1,1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 105:
		predicted_opponent_vector = Vector2(1,-1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 106:
		predicted_opponent_vector = Vector2(-1,1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_left = 1
	elif predicted_action == 107:
		predicted_opponent_vector = Vector2(-1,-1)
		predicted_opponent_psuedo_ability = 1
		predicted_opponent_aim_left = 1

func get_predictions():
	var pred = []
	pred.append((predicted_opponent_position))
	pred.append((predicted_opponent_mouse))
	pred.append((predicted_opponent_vector))
	pred.append((predicted_opponent_psuedo_primary))
	pred.append((predicted_opponent_psuedo_secondary))
	pred.append((predicted_opponent_psuedo_ability))
	pred.append((predicted_opponent_in_peril))

	pred.append((predicted_bot_position))
	pred.append((predicted_bot_mouse))
	pred.append((predicted_bot_vector))
	pred.append((predicted_bot_psuedo_primary))
	pred.append((predicted_bot_psuedo_secondary))
	pred.append((predicted_bot_psuedo_ability))
	pred.append((predicted_bot_aim_right))
	pred.append((predicted_bot_aim_left))
	return pred
