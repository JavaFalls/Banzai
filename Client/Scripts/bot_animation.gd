extends Node2D

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_ANIMATION_PLAYER = "AnimationPlayer"
const NP_BASE = "base_layer"
const NP_PRIMARY_COLOR = "primary_color"
const NP_SECONDARY_COLOR = "secondary_color"
const NP_ACCENT_COLOR = "accent_color"

const ANIMATION_SET_HOVER_BOT = "hover_bot"
const ANIMATION_SET_B1 = "B1"

const ANIMATION_NONE = 0
const ANIMATION_WALKING = 1
const ANIMATION_WALKING_BACKWARD = -1
# Local variables
#-------------------------------------------------------------------------------
var bot_type
var cur_animation

# Pre initialized variables
#-------------------------------------------------------------------------------
onready var animation_player = get_node(NP_ANIMATION_PLAYER)
onready var layer_base = get_node(NP_BASE)
onready var layer_primary_color = get_node(NP_PRIMARY_COLOR)
onready var layer_secondary_color = get_node(NP_SECONDARY_COLOR)
onready var layer_accent_color = get_node(NP_ACCENT_COLOR)

# Godot Hooks:
#-------------------------------------------------------------------------------
func _ready():
	# Called when the node is added to the scene for the first time.
	bot_type = ANIMATION_SET_B1

# Other Functions
#-------------------------------------------------------------------------------
func load_colors_from_DB(bot_ID):
	var raw_JSON = head.DB.get_bot(bot_ID)
	if (raw_JSON != ""):
		var bot_dictionary = JSON.parse(raw_JSON).result["data"][0]
		set_primary_color(Color(int(bot_dictionary["primary_color"])))
		set_secondary_color(Color(int(bot_dictionary["secondary_color"])))
		set_accent_color(Color(int(bot_dictionary["accent_color"])))

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

func get_accent_color():
	return layer_accent_color.modulate
func set_accent_color(color):
	layer_accent_color.modulate = color

# Refer to ANIMATION_SET_ constants when passing values to this function
func set_bot_type(animation_set):
	bot_type = animation_set
	layer_base.animation = bot_type
	layer_primary_color.animation = bot_type
	layer_secondary_color.animation = bot_type
	layer_accent_color.animation = bot_type

# Animation Functions
#-------------------------------------------------------------------------------
func face_left():
	layer_base.flip_h = false
	layer_primary_color.flip_h = false
	layer_secondary_color.flip_h = false
	layer_accent_color.flip_h = false
func face_right():
	layer_base.flip_h = true
	layer_primary_color.flip_h = true
	layer_secondary_color.flip_h = true
	layer_accent_color.flip_h = true
func start_walking_forward():
	if (cur_animation != ANIMATION_WALKING):
		animation_player.play(bot_type)
		animation_player.seek(0.1)
		cur_animation = ANIMATION_WALKING
func start_walking_backward():
	if (cur_animation != ANIMATION_WALKING_BACKWARD):
		animation_player.play_backwards(bot_type)
		cur_animation = ANIMATION_WALKING_BACKWARD
func stop_animation():
	animation_player.stop(false)
	cur_animation = ANIMATION_NONE
func reset_animation():
	animation_player.stop(true)
	animation_player.seek(0, true)
	cur_animation = ANIMATION_NONE