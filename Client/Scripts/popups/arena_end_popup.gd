extends Node2D
# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_LEFT_BUTTON_TEXT = "left_button/Label"
const NP_LEFT_BUTTON = "left_button"
const NP_RIGHT_BUTTON_TEXT = "right_button/Label"
const NP_RIGHT_BUTTON = "right_button"
const NP_TITLE_TEXT = "title_container/title"
const NP_OPTIONAL_MESSAGE_TEXT = "optional_message_container/optional_message"

# Godot Hooks:
#-------------------------------------------------------------------------------
func _ready():
	$left_button.connect("mouse_entered", self, "button_mouse_entered", [$left_button/Label])
	$right_button.connect("mouse_entered", self, "button_mouse_entered", [$right_button/Label])
	$left_button.connect("mouse_exited", self, "button_mouse_exited", [$left_button/Label])
	$right_button.connect("mouse_exited", self, "button_mouse_exited", [$right_button/Label])

# Functions:
#-------------------------------------------------------------------------------
func init(title_text,
          left_button_text,
		  right_button_text,
		  left_button_receiver_node,      # Node to reference when the left button is pressed
		  left_button_receiver_function,  # Function name to call when the left button is pressed
		  right_button_receiver_node,     # Node to reference when the right button is pressed
		  right_button_receiver_function, # Function name to call when the right button is pressed
		  optional_message=""):
	get_node(NP_TITLE_TEXT).text = title_text
	get_node(NP_LEFT_BUTTON_TEXT).text = left_button_text
	get_node(NP_RIGHT_BUTTON_TEXT).text = right_button_text
	get_node(NP_LEFT_BUTTON).connect("pressed", left_button_receiver_node, left_button_receiver_function)
	get_node(NP_RIGHT_BUTTON).connect("pressed", right_button_receiver_node, right_button_receiver_function)
	get_node(NP_OPTIONAL_MESSAGE_TEXT).text = optional_message
	get_tree().paused = true

func set_background_transparency(value):
	get_node("shade").color = Color(0,0,0,value)

func button_mouse_entered(label):
	label.modulate = Color("#53545a")

func button_mouse_exited(label):
	label.modulate = Color("#2b2c32")