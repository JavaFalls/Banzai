# Handles basic explosions. Intended to be a child of the arena scene but NOT a child of the bot or it's weapons.
# its owner's mouse position
extends Area2D

# Constants

# Stat Variables:
var        damage   = 0

# Other variables:
var things_I_already_hit = Array() # An array of all nodes that have already been damaged by this explosion

# Godot Hooks:
#---------------------------------------------------------
func _ready():
	get_node("AnimatedSprite").play("default")

func _on_projectile_body_entered(body):
	if (body.get_name() == "fighter1" or body.get_name() == "fighter2"):
		# Did we already damage this target?
		for already_damaged_name in things_I_already_hit:
			if (body.get_name() == already_damaged_name):
				# Already damaged target, abort function
				pass
		# Damage target and add to array of damaged targets
		body.increment_hitpoints(damage)
		things_I_already_hit.append(body.get_name())

func _on_AnimatedSprite_animation_finished():
	self.queue_free()