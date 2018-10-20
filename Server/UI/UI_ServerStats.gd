extends MarginContainer

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_UI_CONTAINER = "/root/Master/UI_Container"
const NP_BTN_TOGGLE_SERVER = "VBoxContainer/Footer/HBoxContainer/btnToggleServer"
const NP_BTN_SWITCH_MODE = "VBoxContainer/Footer/HBoxContainer/btnSwitchToScoreboardMode"
const NP_BTN_EXIT = "VBoxContainer/Footer/HBoxContainer/btnExit"
const DEFAULT_NP_UI_SCOREBOARD = "VBoxContainer/Body/UI_Scoreboard"
const NP_BODY = "VBoxContainer/Body"

const TXT_STRT_SERVER = "Start Server"
const TXT_STOP_SERVER = "Stop Server"

# Signals:
#-------------------------------------------------------------------------------
signal server_start()
signal server_stop()
signal scoreboard_projection(enabled)

# Local vars:
#-------------------------------------------------------------------------------
var UI_Scoreboard

# Godot Signal Receivers:
#-------------------------------------------------------------------------------
func _ready():
	# Initialize variables
	UI_Scoreboard = get_node(DEFAULT_NP_UI_SCOREBOARD)

	# Subscribe signals
	Server.connect("server_started", self, "_server_started")
	self.connect("server_start", Server, "_start_server")
	self.connect("server_stop", Server, "_stop_server")
	self.connect("scoreboard_projection", UI_Scoreboard, "_scoreboard_projection")


	# Initialize UI
	enable_buttons()

func _process(delta):
	# Called every frame. Delta is time since last frame.
	if self.visible == false and Input.is_action_just_pressed("close_scoreboard_projection"):
		Utility.create_popup(self, "Return to server statistics?", "_confirm_end_projection", "_deny_end_projection")

# Child Node Signal Receivers
#-------------------------------------------------------------------------------
func _on_btnToggleServer_pressed():
	match Server.serverState:
		Server.SERVER_DOWN:
			emit_signal("server_start")
		Server.SERVER_UP:
			disable_buttons()
			Utility.create_popup(self, "Kill the server?", "_confirm_kill_server", "_deny_kill_server")

func _on_btnSwitchToScoreboardMode_pressed():
	# Take the scoreboard in UI_ServerStats, and make it full screen
	# We do this by orphaning the scoreboard, and then reparenting the scoreboard to Master
	UI_Scoreboard.get_parent().remove_child(UI_Scoreboard)
	get_node(NP_UI_CONTAINER).add_child(UI_Scoreboard)

	# Remove the UI_Stats from the screen
	self.visible = false

func _on_btnExit_pressed():
	# disable buttons and create a confirmation dialog
	disable_buttons()
	match Server.serverState:
		Server.SERVER_UP:
			Utility.create_popup(self, "Exit?\nThis will close the server!", "_confirm_exit", "_deny_exit")
		Server.SERVER_DOWN:
			Utility.create_popup(self, "Exit?", "_confirm_exit", "_deny_exit")

# Parent Node Signal Receivers:
#-------------------------------------------------------------------------------
func _state_changed():
	# UI_Master changed the screen to something else, time for us to say goodbye
	queue_free()

# Server Signal Receivers:
#-------------------------------------------------------------------------------
func _server_started(errorCode):
	match errorCode:
		Server.SERVER_ERROR_SUCCESS:
			enable_buttons()

# Popup Dialog Signal Receivers:
#-------------------------------------------------------------------------------
func _confirm_exit():
	emit_signal("server_stop")
	get_tree().quit()

func _deny_exit():
	enable_buttons()

func _confirm_kill_server():
	emit_signal("server_stop")
	enable_buttons()

func _deny_kill_server():
	enable_buttons()

func _confirm_end_projection():
	# Move scoreboard back into the ServerStats container and display the server statistics
	UI_Scoreboard.get_parent().remove_child(UI_Scoreboard)
	get_node(NP_BODY).add_child(UI_Scoreboard)
	self.visible = true
	enable_buttons()

func _deny_end_projection():
	pass # Nothing to do, just carry on with the projection

# Local Functions:
#-------------------------------------------------------------------------------

# NOTE: Turns out that if another UI element is above a button, then the button
# can't be pressed regardless of whether disabled is false or not. This means
# that disable_buttons() isn't really necessary but we are going to use it just
# in case anyway.

# Disables all ServerStat buttons regardless of server state
func disable_buttons():
	get_node(NP_BTN_TOGGLE_SERVER).disabled = true
	get_node(NP_BTN_EXIT).disabled = true
	get_node(NP_BTN_SWITCH_MODE).disabled = true

# Enables buttons based on current server state
func enable_buttons():
	get_node(NP_BTN_TOGGLE_SERVER).disabled = false
	get_node(NP_BTN_EXIT).disabled = false
	match Server.serverState:
		Server.SERVER_DOWN:
			get_node(NP_BTN_TOGGLE_SERVER).text = TXT_STRT_SERVER
			get_node(NP_BTN_SWITCH_MODE).disabled = true
		Server.SERVER_UP:
			get_node(NP_BTN_TOGGLE_SERVER).text = TXT_STOP_SERVER
			get_node(NP_BTN_SWITCH_MODE).disabled = false
