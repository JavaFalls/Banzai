extends Area2D

onready var animation = get_node("anim_swing")
var damage = 2

func use():
	if !animation.is_playing():
		animation.play("swing_quick",-1, 1.0, false )

func _on_atk_quick_body_entered(body):
	if (body.get_name() != get_parent().get_name()):
		if body.get_name() == "player" or body.get_name() == "bot" or body.get_name() == "dummy":
			body.increment_hitpoints(damage)
		self.call_deferred("set_monitoring",false) 