# Controls the animation effect for charge
extends Node2D

func _ready():
	get_node("AnimatedSprite").play("default")


func _on_AnimatedSprite_animation_finished():
	queue_free()
