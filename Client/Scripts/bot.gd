extends "res://Scripts/entity.gd"

func _ready():
	pass

func send_nn_state():
	var output = []
	var path = PoolStringArray() 
	var predictions = []
	var y = 0
	path.append('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/NeuralNetwork/client.py')
	path.append(opponent.get_state())
	path.append(self.get_position())
	path.append(self.get_trajectory())

	OS.execute('python', path, true, output)
	
	output = output[0].split_floats(',', false)
	
	for x in output:
		x = int(x)
		predictions.append(x)
		
		
	return predictions

func _process(delta):
	var predictions = send_nn_state()
	print(predictions)
	direction = Vector2(0,0)
	if not predictions.empty():
		if predictions[8] == 1:
			direction.x = 1
		if predictions[9] == 1:
			direction.x = -1
		if predictions[8] == 1 and predictions[9] == 1:
			direction.x = 0

		if predictions[10] == 1:
			direction.y = -1
		if predictions[11]:
			direction.y = 1
		if predictions[10] and predictions[11]:
			direction.y = 0

func _physics_process(delta):
	direction = move_and_slide(direction.normalized()*movement_speed, UP)