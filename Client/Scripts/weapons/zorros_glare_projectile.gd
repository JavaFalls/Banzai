# This projectile scene is instanced by the zorros_glare scene and targets
# its owner's mouse position.
# Deals damage to other bots for as long as they stand in the laser
extends Area2D

# Constants
const DAMAGE_FREQUENCY = 0.1 # How often, in seconds, to damage bots standing in the laser

# Stat Variables:
var        id       = -1
var        damage   = 0

# Other variables:
var projectile_owner # The bot that fired the projectile, this way we can make sure we don't hurt ourselves
var zorros_glare # An instance of the Zorro's Glare weapon. We use this to determine how much damage to deal
var damage_list = Array() # Array of bots that are currently standing in the laser
var damage_timer = Timer.new()

# Godot Hooks:
#---------------------------------------------------------
func _ready():
	damage_timer.wait_time = DAMAGE_FREQUENCY
	damage_timer.one_shot = false
	add_child(damage_timer)
	damage_timer.connect("timeout", self, "_damage_timer_timeout")
	damage_timer.start()

func _damage_timer_timeout():
	for bot in damage_list:
		bot.increment_hitpoints(zorros_glare.damage)

func _on_zorros_glare_projectile_body_entered(body):
	if body.is_in_group("damageable") and body.get_instance_id() != projectile_owner.get_instance_id():
		damage_list.append(body)

func _on_zorros_glare_projectile_body_exited(body):
	if body.is_in_group("damageable"):
		damage_list.erase(body)

# Functions:
#---------------------------------------------------------
func set_sprite(value):
	get_node("Sprite").texture = value
