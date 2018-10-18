extends MarginContainer

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_BTN_TOGGLE_SERVER = "VBoxContainer/Footer/HBoxContainer/btnToggleServer"
const NP_BTN_SWITCH_MODE = "VBoxContainer/Footer/HBoxContainer/btnSwitchToScoreboardMode"
# const NP_BTN_EXIT = "VBoxContainer/Footer/HBoxContainer/btnExit"

const TXT_STRT_SERVER = "Start Server"
const TXT_STOP_SERVER = "Stop Server"

# Signals:
#-------------------------------------------------------------------------------
signal change_state(newState)
signal server_start()
signal server_stop()
signal exit()

# Standard Functions:
#-------------------------------------------------------------------------------
func _ready():
	# Subscribe to signals
	self.connect("change_state", get_parent(), "_state_changed")
	self.connect("server_start", state, "_server_started")

	# Initialize UI
	update_UI()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	pass

# UI_ServerStats signal receivers:
#-------------------------------------------------------------------------------
func _on_btnToggleServer_pressed():
	match state.serverState:
		state.SERVER_DOWN:
			emit_signal("server_start")
		state.SERVER_UP:
			emit_signal("server_stop")

func _on_btnSwitchToScoreboardMode_pressed():
	emit_signal("change_state", get_parent().STATE_SCOREBOARD)

func _on_btnExit_pressed():
	pass # replace with function body

# UI_Master Signal Receivers:
#-------------------------------------------------------------------------------
func _state_changed():
	# UI_Master changed the screen to something else, time for us to say goodbye
	queue_free()

# state Signal Receivers:
#-------------------------------------------------------------------------------
func _server_started(errorCode):
	match errorCode:
		state.SERVER_ERROR_SUCCESS:
			update_UI()


# UI_ServerStats Functions:
#-------------------------------------------------------------------------------
func update_UI():
	match state.serverState:
		state.SERVER_DOWN:
			get_node(NP_BTN_TOGGLE_SERVER).text = TXT_STRT_SERVER
			get_node(NP_BTN_SWITCH_MODE).disabled = true
		state.SERVER_UP:
			get_node(NP_BTN_TOGGLE_SERVER).text = TXT_STOP_SERVER
			get_node(NP_BTN_SWITCH_MODE).disabled = false
