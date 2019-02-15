# This is a singleton. See autoload tab in project settings through Godot's GUI
extends Node

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
# External use constants:
const COLOR_GREEN = Color(0,255,0) # TODO: Comment about use of colors
const COLOR_YELLOW = Color(0,255,255)
const COLOR_RED = Color(255,0,0)
const COLOR_WHITE = Color(255,255,255)

const COLOR_SUBJECT_SERVER = COLOR_GREEN

const LIST = preload("res://Utility_Classes/List.gd")

# Internal use constants:
const NP_CANVAS_POPUPS = "/root/Master/Popups"
const NP_SERVER_STATS = "/root/Master/UI_Container/UI_ServerStats"
const DEFAULT_NP_INCOMING_REQUEST_LIST_ACTUAL_LIST = "/root/Master/UI_Container/UI_ServerStats/VBoxContainer/Body/UI_IncomingRequestList/VBoxContainer/RequestList(VBoxContainer)"

const FP_UI_POPUP = "res://UI/UI_CustomPopup.tscn"
const FP_UI_MESSAGE = "res://UI/UI_MessageRequest.tscn"

# Global vars:
#-------------------------------------------------------------------------------

# Local vars:
#-------------------------------------------------------------------------------
var messageContainer

# Signals
#-------------------------------------------------------------------------------

# Godot Signal Receivers:
#-------------------------------------------------------------------------------
func _ready():
   messageContainer = get_node(DEFAULT_NP_INCOMING_REQUEST_LIST_ACTUAL_LIST)

# General Use Functions:
#-------------------------------------------------------------------------------

# create_popup()----------------------------------------------------------------
# requestingNode  = Used to connect confirm/deny signals
# dialog          = message you wish to display to the user (should be a question)
# confirmFunction = function to be called if the user presses the confirm button
# denyFunction    = function to be called if the user presses the deny button
func create_popup(requestingNode, dialog, confirmFunction, denyFunction):
   var node_popup = load(FP_UI_POPUP).instance()
   node_popup.set_dialog(dialog)
   node_popup.connect("confirm", requestingNode, confirmFunction)
   node_popup.connect("deny", requestingNode, denyFunction)
   get_node(NP_CANVAS_POPUPS).add_child(node_popup)

# create_message()--------------------------------------------------------------
func create_message(requestingNode, subject, message, subjectColor, messageColor):
   var node_message = load(FP_UI_MESSAGE).instance()
   node_message.set_subject_color(subjectColor)
   node_message.set_subject_text(subject)
   node_message.set_message_color(messageColor)
   node_message.set_message_text(message)
   messageContainer.add_child(node_message)
   # I was going to do this next part through signals, but apparently nodes can't be passed in a signal
   get_node(NP_SERVER_STATS)._message_created(node_message)
   #emit_signal(node_message)
