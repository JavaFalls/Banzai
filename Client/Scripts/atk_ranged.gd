extends Area2D

# The variables
var cooldown_timer  = Timer.new() # Timer for firing cooldown
var ranged_cooldown = 0.3         # Time for firing cooldown
var bullet          = Area2D      # The name of the projectile instance

onready var projectile           = preload("res://Scenes/projectile.tscn") # The projectile scene to be instanced
onready var projectile_container = get_node("projectile_container")

func _ready():
	cooldown_timer.set_wait_time(ranged_cooldown)
	cooldown_timer.set_one_shot(true)
	projectile_container.add_child(cooldown_timer)
	cooldown_timer.stop()

# Function that is called when the sword hits a body
func use():
	if cooldown_timer.is_stopped():
		bullet = projectile.instance()
		#bullet.set_target(self.get_parent().get_opponent().get_position())
		projectile_container.add_child(bullet)
		cooldown_timer.start()