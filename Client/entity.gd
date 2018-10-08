extends KinematicBody2D

const UP = Vector2(0,0)
const SPEED =  300
var direction = Vector2()

#func _ready():
	#player_node = get_node("player")


#func _physics_process(delta):
#	direction = move_and_slide(direction, UP)
#	direction = Vector2(0,0)
#	pass