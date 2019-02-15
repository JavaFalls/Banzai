extends Node2D

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_ANIMATION_PLAYER = "AnimationPlayer"
const NP_BASE = "AnimationPlayer/base_layer"
const NP_PRIMARY_COLOR = "AnimationPlayer/primary_color"
const NP_SECONDARY_COLOR = "AnimationPlayer/secondary_color"

const ANIMATION_SET_HOVER_BOT = "hover_bot"
const ANIMATION_SET_LAND_BOT = "land_bot"

# Pre initialized variables
#-------------------------------------------------------------------------------
onready var animation_player = get_node(NP_ANIMATION_PLAYER)
onready var layer_base = get_node(NP_BASE)
onready var layer_primary_color = get_node(NP_PRIMARY_COLOR)
onready var layer_secondary_color = get_node(NP_SECONDARY_COLOR)

# Godot Hooks:
#-------------------------------------------------------------------------------
func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	start_walking()
	face_left()
	set_primary_color(Color(1,1,0))
	set_secondary_color(Color(1,1,0))
	var raw_JSON = head.DB.get_bot(head.bot_ID)
	if (raw_JSON != ""):
		var bot_dictionary = JSON.parse(raw_JSON).result["data"][0]
		print(bot_dictionary["primary_color"])
		print(bot_dictionary["secondary_color"])
		set_primary_color(Color(int(bot_dictionary["primary_color"])))
		set_secondary_color(Color(int(bot_dictionary["secondary_color"])))
	set_bot_type(ANIMATION_SET_HOVER_BOT)
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

# Getters and setters
#-------------------------------------------------------------------------------
func get_primary_color():
	return layer_primary_color.modulate
func set_primary_color(color):
	layer_primary_color.modulate = color

func get_secondary_color():
	return layer_secondary_color.modulate
func set_secondary_color(color):
	layer_secondary_color.modulate = color

# Refer to ANIMATION_SET_ constants when passing values to this function
func set_bot_type(animation_set):
	layer_base.animation = animation_set
	layer_primary_color.animation = animation_set
	layer_secondary_color.animation = animation_set

# Animation Functions
#-------------------------------------------------------------------------------
func face_left():
	layer_base.flip_h = true
	layer_primary_color.flip_h = true
	layer_secondary_color.flip_h = true
func face_right():
	layer_base.flip_h = false
	layer_primary_color.flip_h = false
	layer_secondary_color.flip_h = false
func start_walking():
	animation_player.play("hover_bot")
func stop_animation():
	animation_player.stop(false)
func reset_animation():
	animation_player.stop(true)