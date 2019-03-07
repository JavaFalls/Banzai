# This projectile scene is instanced by the atk_range scene and targets
# its owner's mouse position
extends Area2D

# Stat Variables:
var        speed    = 1
var        damage   = 0
var        id       = -1

# Other variables:
var        movement = Vector2()
#var        target   = Vector2()
onready var projectile_owner = get_parent().get_parent().get_parent()
onready var t = Timer.new()
#onready var atk_range_node = get_parent().get_parent() # get atk_range which is the parent of projectile_container

# Helper scenes
onready var explosion = preload("res://Scenes/weapons/explosion.tscn") # Basic explosion that can be instanced.
onready var acid = preload("res://Scenes/weapons/acid.tscn") # Basic acid that can be instanced (deals damage over time).

#func set_target(new_target):
#	self.target = new_target

#x = r cos(theta)
#y = r sin(theta)

# Godot Hooks:
#---------------------------------------------------------
func _ready():
	# Setup the timer
	t.set_wait_time(10)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()

func _physics_process(delta):
	self.global_position += movement*speed*delta                 # move the projectile
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
		match id:
			weapon_creator.W_PRI_EXPLODING_SHURIKEN:
				# Create an explosion
				var boom = explosion.instance()
				boom.id = id
				boom.min_radius = 1.0
				boom.max_radius = 3.0
				boom.expansion_rate = 50.0
				boom.lifetime = 0.25
				boom.damage = damage
				boom.position = global_position
				boom.set_sprite(get_node("Sprite").texture)
				projectile_owner.get_parent().add_child(boom)
			_: # Default case (W_PRI_ACID_BOW, W_PRI_PRECISION_BOW, W_PRI_SCATTER_BOW, W_PRI_RUBBER_BOW, W_PRI_ZORROS_GLARE)
				if body.get_name() == "fighter1" or body.get_name() == "fighter2":
					body.increment_hitpoints(damage)
					if (id == weapon_creator.W_PRI_ACID_BOW):
						# Add acid effect
						var deadly_acid = acid.instance()
						deadly_acid.duration = 2.5
						deadly_acid.frequency = 0.5
						deadly_acid.damage = 1
						body.add_child(deadly_acid)
		self.queue_free()

# Functions:
#---------------------------------------------------------
func set_sprite(value):
	get_node("Sprite").texture = value