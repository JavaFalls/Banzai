extends MarginContainer

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_LBL_POSITION = "text/position"
const NP_LBL_NAME = "text/name"
const NP_LBL_SCORE = "text/score"

enum {TAG_BLUE, TAG_RED, TAG_GREEN}
enum tag_type {TAG_TYPE_NORMAL, TAG_TYPE_UP, TAG_TYPE_DOWN}

# Exported values:
#-------------------------------------------------------------------------------
# Please use the large versions of the tags
export(tag_type) var TAG_TYPE = TAG_TYPE_NORMAL

export(Texture) var TEXTURE_TAG_UP
export(Texture) var TEXTURE_TAG_DOWN
export(Texture) var TEXTURE_TAG_WHITE
#export(Texture) var TEXTURE_TAG_BLUE
#export(Texture) var TEXTURE_TAG_RED
#export(Texture) var TEXTURE_TAG_GREEN

# Signals
signal on_click()

# Internal Variables:
#-------------------------------------------------------------------------------
var mouse_inside

# Godot Hooks:
#-------------------------------------------------------------------------------
func _ready():
	# Called when the node is added to the scene for the first time.
	mouse_inside = false
	if (TAG_TYPE != TAG_TYPE_NORMAL):
		self.mouse_filter = MOUSE_FILTER_STOP
		match TAG_TYPE:
			TAG_TYPE_UP:
				$banner_tag.texture = TEXTURE_TAG_UP
			TAG_TYPE_DOWN:
				$banner_tag.texture = TEXTURE_TAG_DOWN
	else:
		self.mouse_filter = MOUSE_FILTER_IGNORE
		$banner_tag.texture = TEXTURE_TAG_WHITE

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == BUTTON_LEFT:
			emit_signal("on_click")
			accept_event()

# Signal Responders
#-------------------------------------------------------------------------------
func _on_scoreboard_entry_mouse_entered():
	if (TAG_TYPE != TAG_TYPE_NORMAL):
		mouse_inside = true
	print(mouse_inside)

func _on_scoreboard_entry_mouse_exited():
	if (TAG_TYPE != TAG_TYPE_NORMAL):
		mouse_inside = false
	print(mouse_inside)

# Getters and setters
#-------------------------------------------------------------------------------
func get_tag_color():
	return $banner_tag.modulate
	#match $banner_tag.texture:
	#	TEXTURE_TAG_BLUE:
	#		return TAG_BLUE
	#	TEXTURE_TAG_RED:
	#		return TAG_RED
	#	TEXTURE_TAG_GREEN:
	#		return TAG_GREEN
func set_tag_color(new_color):
	#if (TAG_TYPE == TAG_TYPE_NORMAL):
	$banner_tag.modulate = new_color
		#match new_color:
		#	TAG_BLUE:
		#		$banner_tag.texture = TEXTURE_TAG_BLUE
		#	TAG_RED:
		#		$banner_tag.texture = TEXTURE_TAG_RED
		#	TAG_GREEN:
		#		$banner_tag.texture = TEXTURE_TAG_GREEN

func get_position():
	if (TAG_TYPE == TAG_TYPE_NORMAL):
		return int(get_node(NP_LBL_POSITION).text)
	else:
		return -1
func set_position(new_position):
	if (TAG_TYPE == TAG_TYPE_NORMAL):
		get_node(NP_LBL_POSITION).text = String(new_position)
	# Don't display the position number for other tag types (an arrow for the button replaces it)

func get_name():
	return get_node(NP_LBL_NAME).text
func set_name(new_name):
	get_node(NP_LBL_NAME).text = new_name

func get_score():
	return int(get_node(NP_LBL_SCORE).text)
func set_score(new_score):
	get_node(NP_LBL_SCORE).text = String(new_score)