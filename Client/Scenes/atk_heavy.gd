extends Area2D

onready var animation = get_node("anim_swing")

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

func use():
	if !animation.is_playing():
		animation.play("attack",-1, 1.0, false )
