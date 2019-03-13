# acid.gd
# Deals damage overtime to the victim
# Expects to be a child of the victim
# Original implementation of this intends for projectile.tscn to be the one responsible for instancing this scene
extends Node2D

# Stat variables:
	
# Acid stuff
var duration = 2.5 # How long, in seconds, the acid lasts
var frequency = 0.5 # How often to damage the victim
var damage = 1 # How much to damage the victim every frequency

# Variables
var victim
var time_to_next_damage # How much longer, in seconds until the victim is next damaged

func _ready():
	victim = get_parent()
	time_to_next_damage = frequency
	get_node("AnimationPlayer").play("acid")

func _process(delta):
	# Damage victim?
	time_to_next_damage -= delta
	while (time_to_next_damage <= 0.0):
		victim.increment_hitpoints(damage)
		time_to_next_damage += frequency
	# End effect?
	duration -= delta
	if (duration <= 0.0):
		queue_free()
