extends "res://Scripts/entity.gd"
var print_timer = Timer.new()

func _ready():
	self.add_child(print_timer)
	print_timer.set_one_shot(true)
	print_timer.set_wait_time(.3)
	print_timer.start()

func _process(delta):
	
	
	send_nn_state()
	
	#OS.execute('python', path, true, output)
	#for line in output:
		#print(line)


func send_nn_state():
	var output = []
	var path = PoolStringArray() 
	path.append('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/nn.py')
	path.append(player_node.get_state())
	path.append(self.get_position())
	path.append(self.get_trajectory())
	if print_timer.is_stopped():
		#print(path)
		print_timer.set_wait_time(.3)
		print_timer.start()
	#path.append(player_node.get_hit_points())
	#path.append(self.get_hit_points())
	
    # Send the required information to the Neural Network
	#OS.execute('python', path, true, output)


	
func _physics_process(delta):
	direction = Vector2(0,0)
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
		direction.x = 0

	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	if Input.is_action_pressed("ui_down"):
		direction.y = 1
	if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
		direction.y = 0

	direction = move_and_slide(direction*movement_speed, UP)