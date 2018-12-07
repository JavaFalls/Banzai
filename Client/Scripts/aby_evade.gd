extends Area2D

var cooldown    = 1            # Time in seconds that the ability cannot be used after it has been used
var time_active = .1           # Time in seconds that the ability will be active for

onready var cooldown_timer  = get_node("cooldown_timer") # Timer for evade cooldown
onready var active_timer    = get_node("active_timer")   # Timer for how long the ability is active
onready var parent_node     = self.get_parent()          # The bot that uses this ability

func _ready():
	cooldown_timer.set_wait_time(cooldown)
	active_timer.set_wait_time(time_active)

# Called by the bots to activate the ability
func use():
	if cooldown_timer.is_stopped():
		parent_node.movement_speed *= 5
		active_timer.start()
		cooldown_timer.start()

# Function called when the active_timer runs out
func _on_active_timer_timeout():
	parent_node.movement_speed /= 5