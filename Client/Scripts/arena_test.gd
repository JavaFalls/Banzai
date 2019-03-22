extends Node2D

var spawn = Vector2(200,73)              # location of the spawn point
var player                               # player object

onready var id = head.bot_ID if head.construction == head.BOT else head.player_bot_ID
onready var bot_data = JSON.parse(head.DB.get_bot(id)).result["data"][0]
# The preloaded scenes
onready var player_scene    = preload("res://Scenes/player.tscn")

func _ready():
#	 The player's bot or AI
	player = player_scene.instance()
	self.add_child(player)
	player.set_position(spawn)
	player.set_name("player")
	player.set_pause_mode(Node.PAUSE_MODE_STOP)
	player.set_weapons(weapon_creator.create_weapon(bot_data["primary_weapon"]), weapon_creator.create_weapon(bot_data["secondary_weapon"]), weapon_creator.create_weapon(bot_data["utility"]))
	get_node("cooldowns").init(bot_data["primary_weapon"], player.primary_weapon, bot_data["secondary_weapon"], player.secondary_weapon, bot_data["utility"], player.ability)
	player.get_node("animation_bot").load_colors_from_DB(id)
	player.is_player = 1
	player.set_opponent(player);
	
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
