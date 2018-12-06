extends MarginContainer

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_SUBJECT = "HBoxContainer/Subject"
const NP_MESSAGE = "HBoxContainer/Message"

# Signals:
#-------------------------------------------------------------------------------

# Godot Signal Receivers:
#-------------------------------------------------------------------------------
func _ready():
	# Called when the node is added to the scene for the first time.
	pass

# Child Node Signal Receivers
#-------------------------------------------------------------------------------

# Parent Node Signal Receivers:
#-------------------------------------------------------------------------------

# Local Functions:
#-------------------------------------------------------------------------------
func set_subject_color(color): # need to access custom_colors/font_color
	get_node(NP_SUBJECT).set("custom_colors/font_color", color)

func set_subject_text(text):
	get_node(NP_SUBJECT).text = text + ":"

func set_message_color(color):
	get_node(NP_MESSAGE).set("custom_colors/font_color", color)

func set_message_text(text):
	get_node(NP_MESSAGE).text = text

# Remote Functions:
#-------------------------------------------------------------------------------
