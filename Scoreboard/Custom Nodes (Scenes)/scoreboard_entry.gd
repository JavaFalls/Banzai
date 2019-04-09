extends MarginContainer

# Exported values:
#-------------------------------------------------------------------------------
export(Texture) var TEXTURE_TAG_WHITE
#export(Texture) var TEXTURE_TAG_BLUE
#export(Texture) var TEXTURE_TAG_RED
#export(Texture) var TEXTURE_TAG_GREEN

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_SPR_BANNER_TAG = "banner_tag"
const NP_LBL_POSITION = "HBoxContainer/position"
const NP_LBL_NAME = "HBoxContainer/name"
const NP_LBL_SCORE = "HBoxContainer/score"

const TAG_BLUE = 0
const TAG_RED = 1
const TAG_GREEN = 2

# Godot Hooks:
#-------------------------------------------------------------------------------
func _ready():
	# Called when the node is added to the scene for the first time.
	pass

# Getters and setters
#-------------------------------------------------------------------------------
#func get_tag_color():
#	#match get_node(NP_SPR_BANNER_TAG).texture:
#		TEXTURE_TAG_BLUE:
#			return TAG_BLUE
#		TEXTURE_TAG_RED:
#			return TAG_RED
#		TEXTURE_TAG_GREEN:
#			return TAG_GREEN
func set_tag_color(new_color):
	$banner_tag.modulate = new_color
#func set_tag_color(new_color):
#	match new_color:
#		TAG_BLUE:
#			get_node(NP_SPR_BANNER_TAG).texture = TEXTURE_TAG_BLUE
#		TAG_RED:
#			get_node(NP_SPR_BANNER_TAG).texture = TEXTURE_TAG_RED
#		TAG_GREEN:
#			get_node(NP_SPR_BANNER_TAG).texture = TEXTURE_TAG_GREEN

func get_position():
	return get_node(NP_LBL_POSITION).text
func set_position(new_position):
	get_node(NP_LBL_POSITION).text = String(new_position)

func get_name():
	return get_node(NP_LBL_NAME).text
func set_name(new_name):
	get_node(NP_LBL_NAME).text = new_name

func get_score():
	return get_node(NP_LBL_SCORE).text
func set_score(new_score):
	get_node(NP_LBL_SCORE).text = String(new_score)