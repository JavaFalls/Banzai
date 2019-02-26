extends Node2D

var spawn = Vector2(200,73)              # location of the spawn point
var player                               # player object

# The preloaded scenes
onready var player_scene    = preload("res://Scenes/player.tscn")

func _ready():
#	 The player's bot or AI
	player = player_scene.instance()
	self.add_child(player)
	player.set_position(spawn)
	player.set_name("player")
	player.is_player = 1
