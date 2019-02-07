extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_proj_path_body_entered(body):
	if body.get_name() == "fighter1" or body.get_name() == "fighter2":
		body.in_peril += 1


func _on_proj_path_body_exited(body):
	if body.get_name() == "fighter1" or body.get_name() == "fighter2":
		body.in_peril -= 1
