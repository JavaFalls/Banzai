# This is a singleton. See autoload tab in project settings through Godot's GUI
extends Node

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_CANVAS_POPUPS = "/root/Master/Popups"

const FP_POPUP = "res://UI/UI_CustomPopup.tscn"

# Global vars:
#-------------------------------------------------------------------------------

# Godot Signal Receivers:
#-------------------------------------------------------------------------------
func _ready():
   pass

# General Use Functions:
#-------------------------------------------------------------------------------

# create_popup()----------------------------------------------------------------
# requestingNode  = Used to connect confirm/deny signals
# dialog          = message you wish to display to the user (should be a question)
# confirmFunction = function to be called if the user presses the confirm button
# denyFunction    = function to be called if the user presses the deny button
func create_popup(requestingNode, dialog, confirmFunction, denyFunction):
   var popup = load(FP_POPUP).instance()
   popup.set_dialog(dialog)
   popup.connect("confirm", requestingNode, confirmFunction)
   popup.connect("deny", requestingNode, denyFunction)
   get_node(NP_CANVAS_POPUPS).add_child(popup)
