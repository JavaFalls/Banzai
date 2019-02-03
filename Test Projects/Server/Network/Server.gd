# This is a singleton. See autoload tab in project settings through Godot's GUI
extends Node

enum{SERVER_DOWN,SERVER_UP}
enum{SERVER_ERROR_SUCCESS}

# Global vars:
#-------------------------------------------------------------------------------
var serverState

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const PORT = 8080
const MAX_CONNECTIONS = 75

# Signals:
#-------------------------------------------------------------------------------
signal server_started(errorCode)
signal server_stopped()

# Local vars:
#-------------------------------------------------------------------------------
var peer

# Godot Signal Receivers:
#-------------------------------------------------------------------------------
func _ready():
	serverState = SERVER_DOWN

# Child Node Signal Receivers
#-------------------------------------------------------------------------------

# Parent Node Signal Receivers:
#-------------------------------------------------------------------------------

# General Signal Receivers:
#-------------------------------------------------------------------------------
func _start_server():
	if serverState == SERVER_DOWN: # Only start the server if it is currently not running
		# Subscribe to Signals
		get_tree().connect("network_peer_connected", self, "_net_peer_connected")
		get_tree().connect("network_peer_disconnected", self, "_net_peer_disconnected")
		get_tree().connect("connected_to_server", self, "_connected_to_server")
		get_tree().connect("connection_failed", self, "_connection_failed")
		get_tree().connect("server_disconnected", self, "_server_disconnected")

		# Start the Server
		peer = NetworkedMultiplayerENet.new()
		peer.create_server(PORT, MAX_CONNECTIONS) # Does this include the server?
		get_tree().set_network_peer(peer)
		serverState = SERVER_UP
		emit_signal("server_started", SERVER_ERROR_SUCCESS)

		# Log action
		Utility.create_message(self, "Server", "Server started", Utility.COLOR_SUBJECT_SERVER, Utility.COLOR_GREEN)

func _stop_server():
	if serverState == SERVER_UP: # Only shutdown the server if it is currently running
		# Unsubscribe from Signals
		get_tree().disconnect("network_peer_connected", self, "_net_peer_connected")
		get_tree().disconnect("network_peer_disconnected", self, "_net_peer_disconnected")
		get_tree().disconnect("connected_to_server", self, "_connected_to_server")
		get_tree().disconnect("connection_failed", self, "_connection_failed")
		get_tree().disconnect("server_disconnected", self, "_server_disconnected")

		# Close the Server
		peer.close_connection()
		get_tree().set_network_peer(null)
		serverState = SERVER_DOWN
		emit_signal("server_stopped")

		# Log action
		Utility.create_message(self, "Server", "Server stopped", Utility.COLOR_SUBJECT_SERVER, Utility.COLOR_RED)

# Local Functions:
#-------------------------------------------------------------------------------

# Remote Functions:
#-------------------------------------------------------------------------------
