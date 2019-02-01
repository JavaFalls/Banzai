extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
#fighter1 = get_parent().get_node("fighter1")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _process(delta):
	
	self.width = get_parent().get_node("fighter1").get_hit_points() * 10
#	pass
