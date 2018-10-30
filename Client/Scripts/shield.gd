extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

onready var animation = get_node("anim_shield")

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

#func _process(delta):
#	pass

func use():
	if !animation.is_playing():
		animation.play("shield",-1, 1.0, false )