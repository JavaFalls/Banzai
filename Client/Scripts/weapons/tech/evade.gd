#  This scene is instanced by a "subclass" (i.e. "player" or "bot") of the entity scene 
#  using entity's set_weapons() function.  Everything in this scene exists for the purpose
#  of the use() function, which is how this ability is used by the mechs.  
## This ability temporarily adds a speed boost to the mech that uses it.

extends Node2D 

signal use # All weapons must have this signal so that cooldowns can be displayed

# Stats
var id
var cooldown    = 1            # Time in seconds that the ability cannot be used after it has been used

var time_active = .1           # Time in seconds that the ability will be active for
var speed_multi = 5            # The amount to multiply the speed by and then divide once the ability is done

onready var cooldown_timer  = get_node("cooldown_timer") # Timer for evade cooldown
onready var active_timer    = get_node("active_timer")   # Timer for how long the ability is active
onready var parent_node     = self.get_parent()          # The mech that uses this ability
onready var evade_animation = preload("res://scenes/weapons/tech/evade_animation.tscn") # Scene to be instanced for the animation

# Function called as soon as the scene is instanced by its mech
func _ready():
	cooldown_timer.set_wait_time(cooldown)
	active_timer.set_wait_time(time_active)

# Called by the mechs to activate the ability
func use():
	if cooldown_timer.is_stopped():
		parent_node.movement_speed *= speed_multi
		active_timer.start()
		cooldown_timer.start()
		var animation = evade_animation.instance()
		animation.position = parent_node.global_position
		animation.play("default")
		parent_node.get_parent().add_child(animation)
		emit_signal("use") # Notify anybody who cares that we did our thing

# Function called when the active_timer runs out
func _on_active_timer_timeout():
	parent_node.movement_speed /= speed_multi