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
	player.set_pause_mode(Node.PAUSE_MODE_STOP)
	player.is_player = 1
	
	# Set popup as the bottom node
	move_child($exit, player.get_index())

func _input(event):
	if Input.is_action_just_pressed("exit_arena"):
		if not get_tree().is_paused():
			get_tree().set_pause(true)
			$exit.visible = true

func _on_confirm_pressed():
	get_tree().set_pause(false)
	get_tree().change_scene("res://Scenes/Screens/bot_construction.tscn")

func _on_back_pressed():
	get_tree().set_pause(false)
	$exit.visible = false
