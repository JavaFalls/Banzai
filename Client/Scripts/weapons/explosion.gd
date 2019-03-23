# Handles basic explosions. Intended to be a child of the arena scene but NOT a child of the bot or it's weapons.
# its owner's mouse position
extends Area2D

# Constants
const BASE_RADIUS = 4

# Stat Variables:
var        damage   = 0
var        id       = -1

# Explosion variables
var max_radius = 3.0 # The largest radius to reach, given in units of 4 pixels each
var min_radius = 1.0 # The radius to start at, given in units of 4 pixels each
var expansion_rate = 50.0 # How fast to expand per second, given in units of 4 pixels each
var lifetime   = 0.25 # How long the explosion will exist (includes time spent expanding) 

# Other variables:
var things_I_already_hit = Array() # An array of instance ids of all the nodes that have already been damaged by this explosion
#var        target   = Vector2()
#onready var projectile_owner = get_parent().get_parent().get_parent()
onready var t = Timer.new()

#func set_target(new_target):
#	self.target = new_target

#x = r cos(theta)
#y = r sin(theta)

# Godot Hooks:
#---------------------------------------------------------
func _ready():
	# Initial size
	scale.x = min_radius
	scale.y = min_radius
	# Setup the timer
	t.set_wait_time(lifetime)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()

func _physics_process(delta):
	# Expand the radius
	if (scale.x < max_radius):
		scale.x += expansion_rate * delta
		scale.y += expansion_rate * delta
		if (scale.x > max_radius):
			scale.x = max_radius
			scale.y = max_radius
	
	# Kill the explosion after the timer ends
	if t.is_stopped():
		get_parent().remove_child(self)
		self.queue_free()
		t.queue_free()

func _on_projectile_body_entered(body):
	if body.is_in_group("damageable"):
		# Did we already damage this target?
		for already_damaged_id in things_I_already_hit:
			if (body.get_instance_id() == already_damaged_id):
				# Already damaged target, abort function
				pass
		# Damage target and add to array of damaged targets
		body.increment_hitpoints(damage)
		things_I_already_hit.append(body.get_instance_id())

# Functions:
#---------------------------------------------------------
func set_sprite(value):
	get_node("Sprite").texture = value