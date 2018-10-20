extends KinematicBody2D
 
const UP             = Vector2(0,0) # Indicates top-down view
const MOVEMENT_SPEED =  300         # Movement speed of the entity

var p                = Area2D      # New Projectile
var timer            = Timer.new() # Timer for Firing cooldown
var projectile_delay = .3          # Firing cooldown length
var hit_points       = 0           # How many times the entity has been hit
var direction        = Vector2()   # Direction the entity is moving

onready var projectile_container = get_node("projectile_container")   # Where the projectiles are stored
onready var projectile           = preload("res://projectile.tscn") # The projectile scene to be instanced
onready var player_node          = get_parent().get_node("player")  # A reference to the 

#onready var ZZ = get_node("ZZ")

func shoot(target_position):
	#ZZ.add_child(projectile.instance())
	#var p = projectile.instance()
	#projectile_container.add_child(p)
	#p.start_at(get_viewport().get_mouse_position(), get_position())
	p = projectile.instance()
	projectile_container.add_child(p)
	p.set_gravity_scale(0) # There is no gravity in a top-down game
	p.shoot_at_mouse(target_position)
	

func _ready():
	timer.set_wait_time(projectile_delay)
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.stop()

#func _physics_process(delta):
#	direction = move_and_slide(direction, UP)
#	direction = Vector2(0,0)
#	pass
func restart_timer(delay):
	timer.set_wait_time(delay)

	timer.start()

func get_hit_points():
	return hit_points
	
func choose_weapon(weapon_choice):
	# GDScript does support case statements
	if weapon_choice is 1:
		pass
