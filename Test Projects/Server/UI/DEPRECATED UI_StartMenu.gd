extends MarginContainer

# Signals:
#-------------------------------------------------------------------------------
signal start_server()

# Standard Functions:
#-------------------------------------------------------------------------------
func _ready():
	# Called when the node is added to the scene for the first time.
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	pass

# UI_StartMenu signal receivers:
#-------------------------------------------------------------------------------
func _on_btnStartServer_pressed():
	emit_signal("start_server")

# UI_Master Signal Receivers:
#-------------------------------------------------------------------------------
func _body_changed():
	# UI_Master changed the body to something else, time for us to say goodbye
	queue_free()

# UI_StartMenu Functions:
#-------------------------------------------------------------------------------
