tool
extends EditorPlugin

# Initialization of the plugin goes here
func _enter_tree():
	add_custom_type("Custom Button", "Button", preload("button.gd"), preload("icon.png"))
	pass

# Clean-up of the plugin goes here
func _exit_tree():
	remove_custom_type("Custom Button")
	pass

# Look in Project Settings/Plugins to active the plugins.