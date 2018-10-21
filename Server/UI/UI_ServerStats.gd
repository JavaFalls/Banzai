extends MarginContainer

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_UI_CONTAINER = "/root/Master/UI_Container"
const NP_BTN_TOGGLE_SERVER = "VBoxContainer/Footer/HBoxContainer/btnToggleServer"
const NP_BTN_SWITCH_MODE = "VBoxContainer/Footer/HBoxContainer/btnSwitchToScoreboardMode"
const NP_BTN_EXIT = "VBoxContainer/Footer/HBoxContainer/btnExit"
const NP_UI_INCOMING_REQUEST_LIST = "VBoxContainer/Body/UI_IncomingRequestList"
const DEFAULT_NP_UI_SCOREBOARD = "VBoxContainer/Body/UI_Scoreboard"
const NP_BODY = "VBoxContainer/Body"
const NP_FOOTER = "VBoxContainer/Footer"

const TXT_STRT_SERVER = "Start Server"
const TXT_STOP_SERVER = "Stop Server"

const MYSTERIOUS_MARGIN = 4 # Godot puts a margin of 4 pixels between UI elements. I have no idea why.


# Signals:
#-------------------------------------------------------------------------------
signal server_start()
signal server_stop()
signal scoreboard_projection(enabled)

# Local vars:
#-------------------------------------------------------------------------------
var UI_Scoreboard
var message_list
var MAX_REQUEST_LIST_HEIGHT = 9999 # Used as a constant but has to be a variable because it's value is determined in the _ready() function
                                   # Yes, it is given the value 9999 here but that is just because the request list gets resized when it is created before we are able to actually initialize MAX_REQUEST_LIST_HEIGHT
# Godot Signal Receivers:
#-------------------------------------------------------------------------------
func _ready():
	# Initialize variables
	UI_Scoreboard = get_node(DEFAULT_NP_UI_SCOREBOARD)
	message_list = Utility.LIST.new()
	MAX_REQUEST_LIST_HEIGHT = get_node(NP_FOOTER).rect_position.y - get_node(NP_BODY).rect_position.y - MYSTERIOUS_MARGIN
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

func _on_UI_IncomingRequestList_resized():
	if get_node(NP_UI_INCOMING_REQUEST_LIST).rect_size.y > MAX_REQUEST_LIST_HEIGHT:
		# If we do not orphan the child before freeing it from the list, for some reason Godot never shrinks the request list back to size
		message_list.first_item.item.get_parent().remove_child(message_list.first_item.item)
		message_list.remove_front()

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

# Utility Signal Receivers:
#-------------------------------------------------------------------------------
func _message_created(node_message):
	message_list.append_back(node_message)

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
