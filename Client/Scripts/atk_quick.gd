extends Area2D

onready var animation = get_node("anim_swing") # Contains all of the sword animations
var damage = 2                                 # Amount of damage this sword does to the opponents hit_points

# Called by the bots to activate the ability
func use():
	if !animation.is_playing():
		animation.play("swing_quick",-1, 1.0, false )

# Function that is called when the sword hits a body
func _on_atk_quick_body_entered(body):
	if (body.get_name() != get_parent().get_name()):
		if body.get_name() == "player" or body.get_name() == "bot" or body.get_name() == "dummy":
			body.increment_hitpoints(damage)
		self.call_deferred("set_monitoring",false)