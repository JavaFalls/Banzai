# This projectile scene is instanced by the atk_range scene and targets
# its owner's mouse position
extends Area2D

export var speed    = 10
var        damage   = 2
var        movement = Vector2()
var        target   = Vector2()
onready var projectile_owner = get_parent().get_parent().get_parent()
onready var t = Timer.new()
onready var atk_range_node = get_parent().get_parent() # get atk_range which is the parent of projectile_container

func set_target(new_target):
	self.target = new_target
	pass

func _ready():
	set_target(projectile_owner.psuedo_mouse)
#	set_fixed_process(true)
	#if projectile_owner.is_player() == true: 
	#	target = get_global_mouse_position()
	#else:
	#	target = projectile_owner.get_opponent().get_position()
	self.global_position = atk_range_node.global_position
	self.look_at(target)
	movement = (target - atk_range_node.global_position).normalized()
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
#	if not area.get_name() == "proj_path":
#		queue_free()
	# Freeing is handled by _on_projectile_body_entered(body)
	pass

func _on_projectile_body_entered(body):
	if (body.get_name() != projectile_owner.get_name()):
		if body.get_name() == "fighter1" or body.get_name() == "fighter2":
			body.increment_hitpoints(damage)
		self.queue_free()