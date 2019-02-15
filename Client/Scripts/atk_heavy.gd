#  This scene is instanced by a "subclass" (i.e. "player" or "bot") of the entity scene 
#  using entity's set_weapons() function.  Everything in this scene exists for the purpose
#  of the use() function, which is how this attack is used by the mechs.  
## This attack slowly swings a powerful sword.

extends Area2D

onready var animation = get_node("anim_swing") # Contains all of the sword animations
var damage = 5                                 # Amount of damage this sword does to the opponents hit_points

# Called by the bots to activate the ability
func use():
	if !animation.is_playing():
		animation.play("attack",-1, 1.0, false )

# Function that is called when the sword hits a body
func _on_atk_heavy_body_entered(body):
	if (body.get_name() != get_parent().get_name()):
		if body.get_name() == "fighter1" or body.get_name() == "fighter2":
			body.increment_hitpoints(damage)
		self.call_deferred("set_monitoring",false) 