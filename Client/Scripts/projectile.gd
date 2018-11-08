extends RigidBody2D

var vel = Vector2()
export var speed = 1000
var damage = 2


func _ready():
#	set_fixed_process(true)
	pass
	
func start_at(dir, pos):
		set_rotation(dir)
		set_position(pos)
		vel = Vector2(speed, 0).rotated(dir)
		
func shoot_at_mouse(start_pos): 
	# Setup the timer
	var t = Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	# Create and move the projectile
	self.global_position = start_pos
	self.look_at(get_global_mouse_position())
	var direction = (get_global_mouse_position() - start_pos).normalized()
	self.linear_velocity = direction * speed
	t.start()
	# Kill the projectile after the timer ends
	yield(t, "timeout")
	get_parent().remove_child(self)
	self.queue_free()
	t.queue_free()
		
func _physics_process(delta):
	pass