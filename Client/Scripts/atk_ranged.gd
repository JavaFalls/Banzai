extends Area2D

var cooldown_timer  = Timer.new()
var ranged_cooldown = 0.3
var bullet          = Area2D

onready var projectile           = preload("res://Scenes/projectile.tscn") # The projectile scene to be instanced
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
		cooldown_timer.start()