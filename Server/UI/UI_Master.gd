extends MarginContainer

# Constants and enumerators:
#  NP = "Node Path";
#  FP = "File Path";
#-------------------------------------------------------------------------------
enum {STATE_STATISTICS, STATE_SCOREBOARD}

const FP_UI_SERVERSTATS = "res://UI/UI_ServerStats.tscn"
const FP_UI_SCOREBOARD = "res://UI/UI_Scoreboard.tscn"

var cur_state;

# Signals:
#-------------------------------------------------------------------------------
signal state_changed()
signal server_start()
signal server_stop()
signal exit()

# Standard Functions:
#-------------------------------------------------------------------------------
func _ready():
	# Called when the node is added to the scene for the first time.
	change_state(STATE_STATISTICS)

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

# UI_Master Signal Receivers:
#-------------------------------------------------------------------------------

# UI_Master Functions:
#-------------------------------------------------------------------------------
# Called when UI_Master needs to change state. Manages connecting signals and destorying/instancing nodes
func change_state(new_state):
	emit_signal("state_changed")
	cur_state = new_state
	match new_state:
		STATE_STATISTICS:
			var new_screen = load(FP_UI_SERVERSTATS).instance()
			self.connect("state_changed", new_screen, "_state_changed")
			add_child(new_screen)
		STATE_SCOREBOARD:
			var new_screen = load(FP_UI_SCOREBOARD).instance()
			self.connect("state_changed", new_screen, "_state_changed")
			add_child(new_screen)
