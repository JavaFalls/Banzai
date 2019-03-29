extends Control

func _ready():
	$back_button.connect("pressed", self, "exit")

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
