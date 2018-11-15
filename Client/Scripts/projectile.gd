extends Area2D

var        vel = Vector2()
export var speed = 10
var        damage = 2
var        movement = Vector2()
onready var projectile_owner = get_parent().get_parent().get_parent().get_name()
onready var t = Timer.new()
onready var parent_node = get_parent().get_parent() # get atk_range which is the parent of projectile_container

func _ready():
#	set_fixed_process(true)
	self.global_position = parent_node.global_position
	self.look_at(get_global_mouse_position())
	movement = (get_global_mouse_position() - parent_node.global_position).normalized()
	# Setup the timer
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()

func _physics_process(delta):
	self.global_position += movement*speed                    # move the projectile
	# Kill the projectile after the timer ends
	if t.is_stopped():
		get_parent().remove_child(self)
		self.queue_free()
		t.queue_free()

func _on_projectile_area_entered(area):
	print(area.get_name())
	queue_free()

func _on_projectile_body_entered(body):
	if (body.get_name() != projectile_owner):
		body.increment_hitpoints(damage)
		self.queue_free()
