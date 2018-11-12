extends Area2D

var particles = Particles2D
onready var cooldown_timer  = get_node("cooldown_timer") # Timer for evade cooldown
onready var active_timer    = get_node("active_timer")
onready var parent_node     = self.get_parent()
onready var evade_particles = preload("res://Scenes/part_evade.tscn")

var cooldown    = 1
var time_active = .1

func _ready():
	cooldown_timer.set_wait_time(cooldown)
	active_timer.set_wait_time(time_active)
	#particles = evade_particles.instance()
	#parent_node.add_child(particles)

func use():
	if cooldown_timer.is_stopped():
		parent_node.movement_speed *= 5
		#parent_node.get_node("part_evade").set_emitting(true)
		active_timer.start()
		
		cooldown_timer.start()

func _on_active_timer_timeout():
	parent_node.movement_speed /= 5
	#parent_node.get_node("part_evade").set_emitting(false)