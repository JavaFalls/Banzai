extends Area2D

onready var cooldown_timer = get_node("cooldown_timer") # Timer for evade cooldown
onready var active_timer   = get_node("active_timer")
onready var animation      = get_node("anim_evade")
onready var parent_node    = self.get_parent()
onready var effect         = get_node("Tween")

var cooldown    = 1
var time_active = .1

func _ready():
	cooldown_timer.set_wait_time(cooldown)
	active_timer.set_wait_time(time_active)

func use():
	if cooldown_timer.is_stopped():
		parent_node.movement_speed *= 5
		active_timer.start()
		cooldown_timer.start()

func _on_active_timer_timeout():
	parent_node.movement_speed /= 5
