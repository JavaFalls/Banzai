extends Node
onready var player_x = 0
onready var player_y = 0
onready var player_mouse_x = 0
onready var player_mouse_y = 0
onready var player_vector_x = 0
onready var player_vector_y = 0
onready var player_w        = 0
onready var player_a        = 0
onready var player_s        = 0
onready var player_d        = 0

onready var bot_x = 0
onready var bot_y = 0
onready var bot_mouse_x = 0
onready var bot_mouse_y = 0
onready var bot_vector_x = 0
onready var bot_vector_y = 0
onready var bot_w        = 0
onready var bot_a        = 0
onready var bot_s        = 0
onready var bot_d        = 0

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
	game_state.append(self.bot_w)
	game_state.append(self.bot_a)
	game_state.append(self.bot_s)
	game_state.append(self.bot_d)
	
	
	game_state.append(self.player_x)
	game_state.append(self.player_y)
	game_state.append(self.player_mouse_x)
	game_state.append(self.player_mouse_y)
	game_state.append(self.player_vector_x)
	game_state.append(self.player_vector_y)
	game_state.append(self.player_w)
	game_state.append(self.player_a)
	game_state.append(self.player_s)
	game_state.append(self.player_d)
	
	return game_state
	
func get_training_state():
	var game_state = []
	game_state.append(self.player_x)
	game_state.append(self.player_y)
	game_state.append(self.player_mouse_x)
	game_state.append(self.player_mouse_y)
	game_state.append(self.player_vector_x)
	game_state.append(self.player_vector_y)
	game_state.append(self.player_w)
	game_state.append(self.player_a)
	game_state.append(self.player_s)
	game_state.append(self.player_d)
	
	game_state.append(self.bot_x)
	game_state.append(self.bot_y)
	game_state.append(self.bot_x)
	game_state.append(self.bot_mouse_y)
	game_state.append(self.bot_vector_x)
	game_state.append(self.bot_vector_y)
	game_state.append(self.bot_w)
	game_state.append(self.bot_a)
	game_state.append(self.bot_s)
	game_state.append(self.bot_d)
	return game_state
	
func set_bot_state(bot):
	self.bot_x        = bot.get_x()
	self.bot_y        = bot.get_y()
	self.bot_mouse_x  = bot.get__mouse_x()
	self.bot_vector_x = bot.get_vector_x()
	self.bot_vector_y = bot.get_vector_y()
	self.bot_w        = bot.get_w()
	self.bot_a        = bot.get_a()
	self.bot_s        = bot.get_s()
	self.bot_d        = bot.get_d()
	
func set_player_state(player):
	self.player_x        = player.get_x()
	self.player_y        = player.get_y()
	self.player_mouse_x  = player.get_mouse_x()
	self.player_mouse_y  = player.get_mouse_y()
	self.player_vector_x = player.get_vector_x()
	self.player_vector_y = player.get_vector_y()
	self.player_w        = player.get_w()
	self.player_a        = player.get_a()
	self.player_s        = player.get_s()
	self.player_d        = player.get_d()
	
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

