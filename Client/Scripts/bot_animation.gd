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
const NP_BONUS = "bonus_layer"
const NP_SHADOW = "Sprite"

const ANIMATION_SET_HOVER_BOT = "hover_bot"
const ANIMATION_SET_B1 = "B1"
const ANIMATION_SET_B1_ZORRO = "B1_ZORRO"

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
onready var layer_bonus = get_node(NP_BONUS)
onready var shadow = get_node(NP_SHADOW)

# Godot Hooks:
#-------------------------------------------------------------------------------
func _ready():
	# Called when the node is added to the scene for the first time.
	bot_type = ANIMATION_SET_B1
	cur_animation = ANIMATION_NONE

# Other Functions
#-------------------------------------------------------------------------------
func load_colors_from_DB(bot_ID):
### TEST
	if bot_ID == -1:
		bot_ID = 1
###
	var raw_JSON = head.DB.get_bot(bot_ID)
	if (raw_JSON != ""):
		var bot_dictionary = JSON.parse(raw_JSON).result["data"][0]
		
		var primary_color
		var secondary_color
		var accent_color
		if typeof(bot_dictionary["primary_color"]) != TYPE_INT:
			if typeof(bot_dictionary["primary_color"]) == TYPE_NIL:
				primary_color = 0
			else:
				primary_color = int(bot_dictionary["primary_color"])
		else:
			primary_color = bot_dictionary["primary_color"]
		if typeof(bot_dictionary["secondary_color"]) != TYPE_INT:
			if typeof(bot_dictionary["secondary_color"]) == TYPE_NIL:
				secondary_color = 0
			else:
				secondary_color = int(bot_dictionary["secondary_color"])
		else:
			primary_color = bot_dictionary["secondary_color"]
		if typeof(bot_dictionary["accent_color"]) != TYPE_INT:
			if typeof(bot_dictionary["accent_color"]) == TYPE_NIL:
				accent_color = 0
			else:
				accent_color = int(bot_dictionary["accent_color"])
		else:
			accent_color = bot_dictionary["accent_color"]
		
		if typeof(bot_dictionary["animation"]) == TYPE_NIL:
			set_bot_type(ANIMATION_SET_B1)
		else:
			set_bot_type(bot_dictionary["animation"])
		set_primary_color(Color(primary_color))
		set_secondary_color(Color(secondary_color))
		set_accent_color(Color(accent_color))

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

func is_facing_right():
	return layer_base.flip_h

# Refer to ANIMATION_SET_ constants when passing values to this function
func set_bot_type(animation_set):
	bot_type = animation_set
	match bot_type:
		ANIMATION_SET_B1_ZORRO:
			layer_base.animation = ANIMATION_SET_B1
			layer_primary_color.animation = ANIMATION_SET_B1
			layer_secondary_color.animation = ANIMATION_SET_B1
			layer_accent_color.animation = ANIMATION_SET_B1
			layer_bonus.animation = ANIMATION_SET_B1_ZORRO
		_:
			layer_base.animation = bot_type
			layer_primary_color.animation = bot_type
			layer_secondary_color.animation = bot_type
			layer_accent_color.animation = bot_type
			layer_bonus.animation = bot_type

# Animation Functions
#-------------------------------------------------------------------------------
func face_left():
	layer_base.flip_h = false
	layer_primary_color.flip_h = false
	layer_secondary_color.flip_h = false
	layer_accent_color.flip_h = false
	layer_bonus.flip_h = false
	shadow.offset.x = 1
func face_right():
	layer_base.flip_h = true
	layer_primary_color.flip_h = true
	layer_secondary_color.flip_h = true
	layer_accent_color.flip_h = true
	layer_bonus.flip_h = true
	shadow.offset.x = -1
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
	if (cur_animation != ANIMATION_NONE):
		animation_player.seek(0, true)
		animation_player.stop(true)
		cur_animation = ANIMATION_NONE