# This projectile scene is instanced by the projectile_launcher scene and targets
# its owner's mouse position
extends Area2D

# Constants:
const FREEZE_DURATION = 0.5
const DEFLECTOR_DAMAGE_REDUCTION = 0.5

# Stat Variables:
var        id       = -1
var        speed    = 1
var        damage   = 0

# Other variables:
var        movement = Vector2()
onready var projectile_owner = get_parent().get_parent().get_parent()
onready var t = Timer.new()

# Helper scenes
onready var explosion = preload("res://Scenes/weapons/explosion.tscn") # Basic explosion that can be instanced.
onready var acid = preload("res://Scenes/weapons/acid.tscn") # Basic acid that can be instanced (deals damage over time).
onready var freeze = preload("res://Scenes/weapons/freeze_effect.tscn") # Freeze affect that freezes its target for the specified duration

# Godot Hooks:
#---------------------------------------------------------
func _ready():
	# Setup the timer
	t.set_wait_time(5.0)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()

func _physics_process(delta):
	self.global_position += movement*speed*delta                 # move the projectile
	# Kill the projectile after the timer ends
	if global_position.x <= -200 or global_position.x > 625 or global_position.y < -200 or global_position.y > 400:
		queue_free()
	elif t.is_stopped():
		self.queue_free()

func _on_projectile_body_entered(body):
	if (body.get_instance_id() != projectile_owner.get_instance_id()):
		if body.is_in_group("deflector"):
			deflect(body)
		match id:
			weapon_creator.W_PRI_EXPLODING_SHURIKEN:
				# Create an explosion
				var boom = explosion.instance()
				boom.id = id
				boom.min_radius = 1.0 * scale.x
				boom.max_radius = 3.5 * scale.x
				boom.expansion_rate = 50.0 * scale.x
				boom.lifetime = 0.15
				boom.damage = damage
				boom.position = global_position
				#boom.set_sprite(get_node("Sprite").texture)
				projectile_owner.get_parent().add_child(boom)
				if not body.is_in_group("deflector"):
					self.queue_free() # Go ahead and free ourselves even if we hit something that wasn't damageable (like a wall)
			weapon_creator.W_PRI_RUBBER_BOW:
				# If we hit a fighter, act like a normal projectile, however, if we hit a wall,
				# we need to bounce off of the wall. Body_entered does not provide enough information to
				# know how to bounce, so the bounce is handled by shape_entered
				if body.is_in_group("damageable"):
					if body.is_in_group("deflector"):
						deflect(body)
					body.increment_hitpoints(damage)
					if not body.is_in_group("deflector"):
						self.queue_free() # Only free rubber_bow projectiles if we hit a damageable target (other projectiles free upon impact with a wall)
			weapon_creator.W_ABI_FREEZE:
				if body.is_in_group("damageable"):
					# 'freeze' the target
					body.immobilized += FREEZE_DURATION
					body.disabled += FREEZE_DURATION
					# Add a 'frozen' effect to the target
					var frozen = freeze.instance()
					frozen.duration = FREEZE_DURATION
					body.add_child(frozen)
				if not body.is_in_group("deflector"):
					self.queue_free()
			_: # Default case (W_PRI_ACID_BOW, W_PRI_PRECISION_BOW, W_PRI_SCATTER_BOW)
				if body.is_in_group("damageable"):
					body.increment_hitpoints(damage)
					if (id == weapon_creator.W_PRI_ACID_BOW):
						# Add acid effect
						var deadly_acid = acid.instance()
						deadly_acid.duration = 2.5
						deadly_acid.frequency = 0.5
						deadly_acid.damage = 1
						body.add_child(deadly_acid)
				if not body.is_in_group("deflector"):
					self.queue_free()

# body_id - int ID of the body we hit
# body - the body we hit
# body_shape - the shape we hit
# area_shape - our shape
func _on_projectile_body_shape_entered(body_id, body, body_shape_ID, area_shape_ID):
	if id == weapon_creator.W_PRI_RUBBER_BOW:
		# Did we hit a wall? If so bounce
		#if body.get_name().ends_with("wall"):
		if body.is_in_group("wall"):
			# New Solution:-----------------------------
			# We know that we are dealing with squares, therefore the possible normalized vector lines we can bounce off of are:
			# VECTOR_SIDE_LEFT, VECTOR_SIDE_RIGHT, VECTOR_SIDE_TOP, VECTOR_SIDE_BOTTOM
			var body_collision_shape = body.shape_owner_get_owner(body.shape_find_owner(body_shape_ID))
			var hit_horizontal_side = false
			var hit_vertical_side = false
			var point1 = global_position
			var point2 = global_position + movement
			var top_left_corner = Vector2(body_collision_shape.global_position.x - body_collision_shape.shape.extents.x, body_collision_shape.global_position.y - body_collision_shape.shape.extents.y)
			var bottom_right_corner = Vector2(body_collision_shape.global_position.x + body_collision_shape.shape.extents.x, body_collision_shape.global_position.y + body_collision_shape.shape.extents.y)
			# Precalculate the x and y distances between the two points.
			# This is necessary because inaccuracies in floating point calculations can result in point1 and point2 sharing the same x or y coordinate even when movement.x or movement.y is not equal to zero
			var delta_x = point2.x - point1.x
			var delta_y = point2.y - point1.y
			if delta_x == 0.0:
				# Course of movement is vertical, therefore we must have hit a horizontal side
				hit_vertical_side = true
			elif movement.x > 0.0:
				# Did we smash the left side of the collision rectangle shape?
				# (((y2 - y1) * (other_x - x2)) / (x2 - x1)) + y1
				var y_possible_contact = (((delta_y) * (top_left_corner.x - point2.x)) / (delta_x)) + point1.y
				if (y_possible_contact >= top_left_corner.y and y_possible_contact <= bottom_right_corner.y):
					hit_vertical_side = true
			else: # movement.x < 0.0
				# Did we smash the right side of the collision rectangle shape?
				var y_possible_contact = (((delta_y) * (bottom_right_corner.x - point2.x)) / (delta_x)) + point1.y
				if (y_possible_contact >= top_left_corner.y and y_possible_contact <= bottom_right_corner.y):
					hit_vertical_side = true
			if delta_y == 0.0:
				# Course of movement is vertical, therefore we must have hit a horizontal side
				hit_horizontal_side = true
			elif movement.y > 0.0:
				# Did we smash the top side of the collision rectangle shape?
				# (((other_y - y1) * (x2 - x1)) / (y2 - y1)) + x2
				var x_possible_contact = (((top_left_corner.y - point1.y) * (delta_x)) / (delta_y)) + point2.x
				if (x_possible_contact >= top_left_corner.x and x_possible_contact <= bottom_right_corner.x):
					hit_horizontal_side = true
			else: # movement.y < 0.0:
				# Did we smash the bottom side of the collision rectangle shape?
				# (((other_y - y1) * (x2 - x1)) / (y2 - y1)) + x2
				var x_possible_contact = (((bottom_right_corner.y - point1.y) * (delta_x)) / (delta_y)) + point2.x
				if (x_possible_contact >= top_left_corner.x and x_possible_contact <= bottom_right_corner.x):
					hit_horizontal_side = true

			# Do the bounce now:
			if hit_horizontal_side:
				movement.y = -movement.y
			if hit_vertical_side:
				movement.x = -movement.x
			rotation = movement.angle()

		# Hackish solution:
		#----------------------------------------------------------
		#var body_name = body.get_name()
		#if body_name == "bottom wall" or body_name == "top wall":
		#		movement.y = -movement.y
		#		rotation = movement.angle()
		#elif body_name == "left wall" or body_name == "right wall":
		#		movement.x = -movement.x
		#		rotation = movement.angle()
		#----------------------------------------------------------

# Functions:
#---------------------------------------------------------
func set_sprite(value):
	get_node("Sprite").texture = value

# Reduces damage, and flips the projectiles direction
# If the body is in group "deflector", call this function before call increment_hitpoints()
func deflect(body):
	damage = floor(damage * DEFLECTOR_DAMAGE_REDUCTION)
	movement = -movement
	rotation = movement.angle()
	projectile_owner = body
	#var deflected_projectile = self.duplicate()
	#deflected_projectile.movement = -movement
	#deflected_projectile.rotation = deflected_projectile.movement.angle()
	#deflected_projectile.projectile_owner = body
	#projectile_owner.get_parent().add_child(deflected_projectile)
