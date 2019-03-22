#  This scene is instanced by a "subclass" (i.e. "player" or "bot") of the entity scene 
#  using entity's set_weapons() function.  Everything in this scene exists for the purpose
#  of the use() function, which is how this attack is used by the mechs.  
## This attack quickly swings a weak sword.

extends Node2D

signal use # All weapons must have this signal so that cooldowns can be displayed

# Stat variables
var id
var damage
var cooldown
var swing_scene

# Variables
var sword_swing
var cooldown_time = 0.0
var sheathed = true

# Godot hooks:
func _process(delta):
	if not sheathed:
		if not sword_swing.get_node("AnimationPlayer").is_playing():
			sword_swing.queue_free()
			sheathed = true
			get_node("sheathed_sword").visible = true
	elif get_parent().get_node("animation_bot").is_facing_right():
		get_node("sheathed_sword").flip_h = false
		get_node("sheathed_sword").rotation_degrees = 200
	else:
		get_node("sheathed_sword").flip_h = true
		get_node("sheathed_sword").rotation_degrees = -200
	if cooldown_time > 0.0:
		cooldown_time -= delta

# Called by the bots to activate the ability
func use():
	if sheathed and cooldown_time <= 0.0:
		sheathed = false
		cooldown_time = cooldown
		get_node("sheathed_sword").visible = false
		sword_swing = swing_scene.instance()
		sword_swing.get_node("AnimationPlayer").play("attack")
		sword_swing.connect("body_entered", self, "_on_sword_swing_body_entered")
		get_node("sword_swing_holder").add_child(sword_swing)
		get_node("sword_swing_holder").rotation = get_parent().aim_angle
		emit_signal("use") # Notify anybody who cares that we did our thing

# Function that is called when the sword hits a body
func _on_sword_swing_body_entered(body):
	if (body.get_instance_id() != get_parent().get_instance_id()):
		if body.is_in_group("damageable"):
			body.increment_hitpoints(damage)

# Function used to set the sheathed graphic
func set_sheathed_sprite(value):
	get_node("sheathed_sword").texture = value