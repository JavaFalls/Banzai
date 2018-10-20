extends MarginContainer

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_DIALOG_CONTAINER = "VBoxContainer"
const NP_DIALOG = "VBoxContainer/Question"
const NP_BACKGROUND_PANEL = "Panel"

const PANEL_MARGIN = 20

# Signals:
#-------------------------------------------------------------------------------
signal confirm()
signal deny()

# Godot Signal Receivers:
#-------------------------------------------------------------------------------
func _ready():
	# Called when the node is added to the scene for the first time.
	pass

# Child Node Signal Receivers
#-------------------------------------------------------------------------------
func _on_btnDeny_pressed():
	emit_signal("deny")
	queue_free()

func _on_btnConfirm_pressed():
	emit_signal("confirm")
	queue_free()

func _on_VBoxContainer_resized():
	get_node(NP_BACKGROUND_PANEL).rect_min_size = get_node(NP_DIALOG_CONTAINER).rect_size + Vector2(PANEL_MARGIN, PANEL_MARGIN)

# Parent Node Signal Receivers:
#-------------------------------------------------------------------------------

# State Signal Receivers:
#-------------------------------------------------------------------------------

# Local Functions:
#-------------------------------------------------------------------------------
func set_dialog(message):
	get_node(NP_DIALOG).text = message

# Remote Functions:
#-------------------------------------------------------------------------------
