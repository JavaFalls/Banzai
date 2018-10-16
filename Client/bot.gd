extends "res://entity.gd"


func _process(delta):
	
	
	send_nn_state()
	



func send_nn_state():
	var output = []                # Array for storing neural network responses
	var path   = PoolStringArray() # Neural network path
	
	# Create Neural Network call with all required information
	path.append('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/nn.py')
	path.append(player_node.get_position())
	
	# Send the required information to the Neural Network
	OS.execute('python', path, true, output)
	
func _physics_process(delta):
	direction = Vector2(0,0)
	if Input.is_action_pressed("ui_right"):
		direction.x = SPEED
	if Input.is_action_pressed("ui_left"):
		direction.x = -SPEED
	if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
		direction.x = 0

	if Input.is_action_pressed("ui_up"):
		direction.y = -SPEED
	if Input.is_action_pressed("ui_down"):
		direction.y = SPEED
	if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
		direction.y = 0

	direction = move_and_slide(direction, UP)
	pass