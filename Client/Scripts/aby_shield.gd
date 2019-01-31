#  This scene is instanced by a "subclass" (i.e. "player" or "bot") of the entity scene 
#  using entity's set_weapons() function.  Everything in this scene exists for the purpose
#  of the use() function, which is how this ability is used by the mechs.  
## This ability temporarily adds a shield around the mech that prevents all projectiles from passing through it.

extends Area2D

onready var animation = get_node("anim_shield")

func use():
	if !animation.is_playing():
		animation.play("shield",-1, 1.0, false)