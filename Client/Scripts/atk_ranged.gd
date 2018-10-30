extends Area2D

var cooldown_timer  = Timer.new()
var ranged_cooldown = 0.3
var bullet          = Area2D

onready var projectile = preload("res://Scenes/projectile.tscn") # The projectile scene to be instanced
onready var projectile_container = get_node("projectile_container")

func _ready():
	cooldown_timer.set_wait_time(ranged_cooldown)
	cooldown_timer.set_one_shot(true)
	projectile_container.add_child(cooldown_timer)
	cooldown_timer.stop()

func use():
	if cooldown_timer.is_stopped():
		bullet = projectile.instance()
		projectile_container.add_child(bullet)
		bullet.set_gravity_scale(0) # There is no gravity in a top-down game. can be defaulted to zero (do this)
		bullet.shoot_at_mouse(get_parent().global_position)# this will probably need to come out of the gun eventually
		cooldown_timer.start()