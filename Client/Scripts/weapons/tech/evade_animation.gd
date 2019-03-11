extends AnimatedSprite

func _on_evade_animation_animation_finished():
	queue_free()
