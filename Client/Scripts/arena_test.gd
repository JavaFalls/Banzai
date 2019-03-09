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
	player.set_weapons(weapon_creator.create_weapon(weapon_creator.W_PRI_PRECISION_BOW), weapon_creator.create_weapon(weapon_creator.W_SEC_SCYTHE), weapon_creator.create_weapon(weapon_creator.W_ABI_SHIELD))
	get_node("cooldowns").init(weapon_creator.W_PRI_PRECISION_BOW, player.primary_weapon, weapon_creator.W_SEC_SCYTHE, player.secondary_weapon, weapon_creator.W_ABI_SHIELD, player.ability)
	player.get_node("animation_bot").load_colors_from_DB(head.bot_ID)
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
