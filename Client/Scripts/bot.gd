# for training  TEST: bot x,y,vectorx,vectory,mousex,mousey,botwasd then \n
# and the      LABEL: playerx,y,vectorx,vectory,mousex,mousey,playerwasd

#for predictions TEST: playerx,y,vectorx,vectory,mousex,mousey,playerwasd
#                the reutrn is what the bot should strive to do






	
extends "res://Scripts/entity.gd"
onready var bot_mouse_position = [0,0]
onready var bot_state = self.get_bot_state()
onready var player = self.get_parent().get_child(2)
onready var player_state = player.get_state()
onready var predictions  = send_nn_state()
onready var bot_wasd     = [0,0,0,0] 
func _ready():
	pass
	


func _process(delta):
	var predictions = send_nn_state()
	if not predictions.empty():
		#print(predictions)
		direction = Vector2(0,0)
		if predictions[10] == 1:
			direction.x = 1
		if predictions[9] == 1:
			direction.x = -1
		if predictions[9] == 1 and predictions[10] == 1:
			direction.x = 0

		if predictions[12] == 1:
			direction.y = -1
		if predictions[11] == 1:
			direction.y = 1
		if predictions[11] == 1 and predictions[12] == 1:
			direction.y = 0
									

func _physics_process(delta):
	direction = move_and_slide(direction.normalized()*movement_speed, UP)
	
func get_bot_state():
	
	var state = PoolStringArray() 
	state.append(self.get_position())
	state.append(self.get_trajectory())
	state.append(bot_mouse_position)
	return state
		
		
		
		
func send_nn_state():
	var output = []
	var path = PoolStringArray() 
	var predictions = []
	path.append('C:/Users/vaugh/Desktop/wonderwoman/Banzai/Client/NeuralNetwork/client.py')
	path.append(player.get_state())
	path.append(self.get_state())
	
	

	if (player_state.size() > 0 && bot_state.size() > 0):
		OS.execute('python', path, true, output)
		
		output = output[0].split_floats(',', false)
		for x in output:
			x = round(x)
			x = int(x)
			predictions.append(x)
		print(predictions)
		
		return predictions