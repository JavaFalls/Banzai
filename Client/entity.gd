extends KinematicBody2D


onready var projectile_container = get_node("player_projectiles")
onready var projectile           = preload("res://projectile.tscn")

const UP    = Vector2(0,0) # Dictates down as being the background as opposed to south
const SPEED = 300          # Entity rate of movement 

var direction           = Vector2()   # The 2d movement vector of entity
var projectile_instance = Area2D      # The name of a projectile
var timer               = Timer.new() # Creates a timer for ability cool down purposes
var projectile_delay    = .3          # Shoot ability delay
var hit_points          = 0           # Amount of damage an entity absorbed during a match


func shoot():
	projectile_instance = projectile.instance()
	projectile_container.add_child(projectile_instance)
	projectile_instance.set_gravity_scale(0) # There is no gravity in a top-down game
	projectile_instance.shoot_at_mouse(self.global_position)
	

#func _ready():
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
	
func going_to_be_hit():
	
	