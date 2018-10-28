extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func use():
	self.get_parent(set_position(self.get_parent().get_position()) + Vector2(50,50))