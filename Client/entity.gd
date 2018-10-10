extends KinematicBody2D

const UP = Vector2(0,0)
const SPEED =  300
var direction = Vector2()
var this_node = Node2D
var ev = InputEventAction.new()


#func _ready():
#	this_node = get_node("entity")


#func _physics_process(delta):
#	direction = move_and_slide(direction, UP)
#	direction = Vector2(0,0)
#	pass