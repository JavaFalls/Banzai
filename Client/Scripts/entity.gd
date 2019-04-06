# The "superclass" that "player", "bot", and "dummy" are derived from.
# This scene contains the functions that the derived scenes have in common.

extends KinematicBody2D

const UP             = Vector2(0,0) # Indicates top-down view

var movement_speed   = 100           # Movement speed of the entity
var max_HP           = 500    # The maximum amount of HP the bot can have
var hit_points                       # The hit point counter for the fighter
var direction        = Vector2()     # Direction the entity is moving
var primary_weapon   = null          # Weapon that goes in the first weapon slot
var secondary_weapon = null          # Weapon that goes in the second weapon slot
var ability          = null          # Weapon that goes in the third weapon slot
var opponent         = null          # The bots' opponent
var is_player        = 0        # Is the mech controlled by a player
var relative_mouse   = Vector2()
var psuedo_mouse     = Vector2(0,0)  # This is the players curser position/bot's predicted curser position
var psuedo_primary   = 0             # Is the primary weapon key pressed?
var psuedo_secondary = 0             # Is the secondary weapon key pressed?
var psuedo_ability   = 0             # Is the ability weapon key pressed?
var in_peril         = 0             # Is the mech about to be hit by a projectile?
var aim_angle        = 0
var aim_angle_old    = 0
var aim_angle_diff   = 0
var psuedo_aim_left  = 0
var psuedo_aim_right = 0

var ignore_movement_controls = false # When true, movement inputs from the bot are ignored, used by the 'charge' ability

var shielded = false # When true, the bot takes no damage. Used by the 'shield' ability
var invisible = false # When invisible, the opponents neural network receives incorrect data about the bots location. Used by 'zorro's wit'
var last_known_location = Vector2() # This is the location data that the opponent's neural network receives when the bot is invisible. Used by 'zorro's wit'
var immobilized = 0.0 # How long the bot will be unable to move for. Used by the 'snare' and 'nuke' secondaries and the 'freeze' ability
var disabled = 0.0 # How long the bot will be unable to attack. Used by the 'nuke' secondary and 'freeze' ability

onready var preloaded_damage_text = preload("res://Scenes/weapons/effects/damage_text.tscn")

signal game_end # The signal indicate the the arena match is over

func _ready():
	hit_points = max_HP

# Function to change weapons; is sent weapon scene as a parameter
func set_weapons(new_primary, new_secondary, new_ability):
	# Don't remove children if there aren't any
	if primary_weapon != null:
		primary_weapon.queue_free()
		primary_weapon = null
	if secondary_weapon != null:
		secondary_weapon.queue_free()
		secondary_weapon = null
	if ability != null:
		ability.queue_free()
		ability = null
	primary_weapon   = new_primary
	self.add_child(primary_weapon)
	secondary_weapon = new_secondary
	self.add_child(secondary_weapon)
	ability          = new_ability
	self.add_child(ability)

func get_hit_points():
	return hit_points

func get_trajectory():
	return direction

func increment_hitpoints(damage): # this decremements now because we make health go down.
	if not shielded:
		hit_points -= damage
		var damage_text = preloaded_damage_text.instance()
		damage_text.set_text(str(damage))
		damage_text.position = global_position
		get_parent().add_child(damage_text)

func set_opponent(new_opponent):
	opponent = new_opponent

func get_opponent():
	return opponent

func get_psuedo_mouse():
	return psuedo_mouse

#func is_player():
#	return is_player

#func set_is_player(choice):
#	is_player = choice

func get_state():
	var state = PoolStringArray()
	state.append(self.get_position())
	state.append(self.get_trajectory())
	state.append(psuedo_mouse)
	state.append(Input.is_action_pressed("primary_attack"))
	state.append(Input.is_action_pressed("secondary_attack"))
	state.append(Input.is_action_pressed("ability"))
	return state

# Moves the bot in the current specified direction, unless it is immobilized or frozen
func move_bot():
	# Control bot animation
	if aim_angle > - (PI*0.5) and aim_angle <= (PI*0.5):
		get_node("animation_bot").face_right()
		if direction.x != 0 || direction.y != 0:
			if (direction.x > 0):
				get_node("animation_bot").start_walking_forward()
			else:
				get_node("animation_bot").start_walking_backward()
		else:
			get_node("animation_bot").reset_animation()
	else:
		get_node("animation_bot").face_left()
		if direction.x != 0 || direction.y != 0:
			if (direction.x > 0):
				get_node("animation_bot").start_walking_backward()
			else:
				get_node("animation_bot").start_walking_forward()
		else:
			get_node("animation_bot").reset_animation()
	if immobilized <= 0.0:
		move_and_slide(direction.normalized()*movement_speed, UP)

func _process(delta):
	if get_hit_points() <= 0 and opponent.get_hit_points() != 0:
		emit_signal("game_end")
	if immobilized > 0.0:
		immobilized -= delta
	if disabled > 0.0:
		disabled -= delta
	if opponent != null:
		if opponent.global_position.y > global_position.y:
			# Opponent is below us, so we need to be drawn behind the opponent
			z_index = -1
		else:
			# Opponent is above us, so we need to be drawn on top of the opponent
			z_index = 0

func _physics_process(delta):
	move_bot()