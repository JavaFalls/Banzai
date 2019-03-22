# Controls the graphical effects for Zorro's wit
extends Node2D

func _ready():
	get_node("AnimatedSprite").play("default")

func _on_AnimatedSprite_animation_finished():
	queue_free()
