extends "res://entity.gd"


func _process(delta):
	
	
	send_nn_state()
	
	#OS.execute('python', path, true, output)
	#for line in output:
		#print(line)


func send_nn_state():
	var output = []
	var path = PoolStringArray() 
	path.append('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/nn.py')
	path.append(player_node.get_position())
	OS.execute('python', path, true, output)
	print(output)
	#for line in output:
		#print(line)
	
func _physics_process(delta):
	direction = Vector2(0,0)
	if Input.is_action_pressed("ui_right"):
		direction.x = MOVEMENT_SPEED
	if Input.is_action_pressed("ui_left"):
		direction.x = -MOVEMENT_SPEED
	if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
		direction.x = 0

	if Input.is_action_pressed("ui_up"):
		direction.y = -MOVEMENT_SPEED
	if Input.is_action_pressed("ui_down"):
		direction.y = MOVEMENT_SPEED
	if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
		direction.y = 0

	direction = move_and_slide(direction, UP)
	pass