# Controls the missle launched by the NUKE secondary
# Missile is intended to go straight up, off the screen, and then come back down and blow up at a specified point on the screen
extends Node2D

# Constants
#const ACCELERATION = 500 # The rate, in pixels per second, that the nuke will acclerate upwards at every second
#const ACCELERATION_TIME = 1.0 # The number of seconds for which acceleration will be applied
const GRAVITY = -400 # Downward acceleration appiled to the missile
const TRAVEL_TIME = 1.5 # How many seconds the missile is in the air for

const INITIAL_VELOCITY_Z = ((-GRAVITY) * 0.5) * TRAVEL_TIME # 0 = ((GRAVITY / 2) * (TRAVEL_TIME ^ 2)) + (TRAVEL_TIME * INITIAL_VELOCITY_Z)
 
#const WAIT_TIME_BEFORE_FALL = 2.0 # The amount of time, in seconds, to wait before the nuke falls back down

# Stat variables:
var damage = 0

# Variables to set when instancing this scene
var missile_owner # Bot that launced the missile
var target = Vector2()

# Variables for the scripts private use
var position3d = Vector3() # Store position in the 3 axes since the nuke travels in the non-existant z-axis
var velocity = Vector3() # How fast, in pixels per second, the nuke is traveling

var boom_timer = Timer.new() # How long until the nuke explodes

#var max_y # How far the nuke must rise before falling back down
#var velocity_y = 0.0 # How fast, in pixels per second, the nuke is traveling
#var rising = true # True if the nuke is rising, false if the nuke is falling towards it's target
#var time_before_fall = 0.0 # How long to suspend the nuke in the air before falling back down

onready var nuke_explosion = preload("res://Scenes/weapons/tech/nuke_explosion.tscn")

func _ready():
	position3d = Vector3(position.x, position.y, 0.0)
	velocity = Vector3((target.x - position.x) / TRAVEL_TIME, (target.y - position.y) / TRAVEL_TIME, INITIAL_VELOCITY_Z)
	$sprite_missile.flip_h = velocity.x > 0
	
	boom_timer.wait_time = TRAVEL_TIME
	boom_timer.one_shot = true
	add_child(boom_timer)
	boom_timer.connect("timeout", self, "_boom_timer_timeout")
	boom_timer.start()
	#max_y = position.y - 275

func _process(delta):
	# Modifiy position in 3 axes
	position3d += velocity * delta
	velocity.z += GRAVITY * delta
	
	# Convert position3d to 2 axes
	position = Vector2(position3d.x, position3d.y - position3d.z)
	$sprite_shadow.global_position = Vector2(position3d.x, position3d.y)
	
	# Calculate the current rotation of the missile using slope (slope = z / square_root(x * x + y * y)
	$sprite_missile.rotation = atan(velocity.z / sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))) - PI
	if velocity.x > 0:
		$sprite_missile.rotation = -$sprite_missile.rotation

func _boom_timer_timeout():
	# Target reached, explode:
	var explosion = nuke_explosion.instance()
	explosion.damage = damage
	explosion.position = target
	explosion.scale = scale
	explosion.explosion_owner = missile_owner
	get_parent().add_child(explosion)
	queue_free()
