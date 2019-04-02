extends Control

func _ready():
	var count = 0
	var message
	var output
	var magnitude = []
	$back_button.connect("pressed", self, "exit")
	message = '{ "Message Type":"Get Rewards"}'
	head.Client.send_request(message)
	output = head.Client.get_response()
	output = output.replace("[", " ")
	output = output.replace("]", " ")
	output = output.split_floats(",")
	for x in output:
		magnitude.append(int(x * 10))
	for option in get_tree().get_nodes_in_group("ui_option"):
		option.set_value(magnitude[count])
		count += 1
	
	

func exit():
	var message
	var output
	var rewards = []
	for option in get_tree().get_nodes_in_group("ui_option"):
		rewards.append(option.get_value())
	message = '{ "Message Type":"Set Rewards", "Rewards": "%s" }' % str(rewards)
	head.Client.send_request(message)
	output = head.Client.get_response()
	self.visible = false
