extends Area2D

var vel = Vector2()
export var speed = 1000

func _ready():
#	set_fixed_process(true)
	pass
	
func start_at(dir, pos):
		set_rotation(dir)
		set_position(pos)
		vel = Vector2(speed, 0).rotated(dir)
		
func _physics_process(delta):
		set_position(get_position() + vel + delta)

