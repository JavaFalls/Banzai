extends "res://Scripts/entity.gd"
onready var psuedo_bot_mouse = [0,0]

onready var game_state = self.get_parent().get_child(1)


func _ready():
	pass
	


func _process(delta):
	game_state.set_bot_state(self)
	return								

func _physics_process(delta):
#	if not predictions.empty():
#		direction = Vector2(0,0)
#		if predictions[10] == 1:
#			direction.x = 1
#		if predictions[9] == 1:
#			direction.x = -1
#		if predictions[9] == 1 and predictions[10] == 1:
#			direction.x = 0
#
#		if predictions[12] == 1:
#			direction.y = -1
#		if predictions[11] == 1:
#			direction.y = 1
#		if predictions[11] == 1 and predictions[12] == 1:
#			direction.y = 0	
	direction = move_and_slide(direction.normalized()*movement_speed, UP)
	return

func get_psuedo_mouse():
	return psuedo_bot_mouse		
		
		
		
func send_nn_state():
	var output = []
	var path = PoolStringArray() 
	var predictions = []
#	path.append('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/NeuralNetwork/client.py')
#	path.append(player.get_state())
#	path.append(self.get_state())
#	OS.execute('python', path, true, output)
#	output = output[0].split_floats(',', false)
#	for x in output:
#		x = round(x)
#		x = int(x)
#		predictions.append(x)
	return predictions