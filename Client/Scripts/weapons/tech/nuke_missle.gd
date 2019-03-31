# Controls the missle launched by the NUKE secondary
# Missile is intended to go straight up, off the screen, and then come back down and blow up at a specified point on the screen
extends Node2D

# Constants
const ACCELERATION = 500 # The rate, in pixels per second, that the nuke will acclerate upwards at every second
const WAIT_TIME_BEFORE_FALL = 2.0 # The amount of time, in seconds, to wait before the nuke falls back down

# Stat variables:
var damage = 0

# Variables to set when instancing this scene
var target = Vector2()

# Variables for the scripts private use
var max_y # How far the nuke must rise before falling back down
var velocity_y = 0.0 # How fast, in pixels per second, the nuke is traveling
var rising = true # True if the nuke is rising, false if the nuke is falling towards it's target
var time_before_fall = 0.0 # How long to suspend the nuke in the air before falling back down

onready var nuke_explosion = preload("res://Scenes/weapons/tech/nuke_explosion.tscn")

func _ready():
	max_y = position.y - 275

func _process(delta):
	if time_before_fall <= 0.0:
		if rising:
			velocity_y -= ACCELERATION * delta
		else:
			velocity_y += ACCELERATION * delta * 2.0
		position.y += velocity_y * delta
		if position.y <= max_y and rising:
			# Reached max height, start falling
			rising = false
			velocity_y = 0
			get_node("Sprite").flip_h = true
			position.x = target.x # Move to fall on target
			time_before_fall = WAIT_TIME_BEFORE_FALL
		elif position.y >= target.y and not rising:
			# Target reached, explode:
			var explosion = nuke_explosion.instance()
			explosion.damage = damage
			explosion.position = target
			explosion.scale = scale
			get_parent().add_child(explosion)
			queue_free()
	else:
		time_before_fall -= delta
