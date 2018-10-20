extends MarginContainer

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------

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

# UI_ServerStats Signal Receivers:
#-------------------------------------------------------------------------------
# Called whenever UI_ServerStats starts or ends a projection of the scoreboard
# Enabled - True if the projection is staring, false if the projection is ending
func _scoreboard_projection(enabled):
	pass

# Local Functions:
#-------------------------------------------------------------------------------

# Remote Functions:
#-------------------------------------------------------------------------------
