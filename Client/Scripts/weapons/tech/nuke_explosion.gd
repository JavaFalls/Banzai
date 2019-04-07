# Handles basic explosions. Intended to be a child of the arena scene but NOT a child of the bot or it's weapons.
# its owner's mouse position
extends Area2D

# Constants

# Stat Variables:
var        damage   = 0

# Other variables:
var explosion_owner
var things_I_already_hit = Array() # An array of instance ids of all the nodes that have already been damaged by this explosion

# Godot Hooks:
#---------------------------------------------------------
func _ready():
	get_node("AnimatedSprite").play("default")

func _on_projectile_body_entered(body):
	if body.is_in_group("damageable"):
		# Did we already damage this target?
		for already_damaged_id in things_I_already_hit:
			if body.get_instance_id() == already_damaged_id:
				# Already damaged target, abort function
				pass
		# Damage target and add to array of damaged targets
		if body.get_instance_id() != explosion_owner.get_instance_id():
			body.increment_hitpoints(damage)
		else:
			body.increment_hitpoints(floor(damage * 0.1))
		things_I_already_hit.append(body.get_instance_id())

func _on_AnimatedSprite_animation_finished():
	self.queue_free()
