# The "superclass" that "player", "bot", and "dummy" are derived from.
# This scene contains the functions that the derived scenes have in common.

extends KinematicBody2D

const UP             = Vector2(0,0) # Indicates top-down view

var movement_speed   = 100           # Movement speed of the entity
var max_HP           = 1000000000    # The maximum amount of HP the bot can have
var hit_points                       # The hit point counter for the fighter
var direction        = Vector2()     # Direction the entity is moving
var primary_weapon                   # Weapon that goes in the first weapon slot
var secondary_weapon                 # Weapon that goes in the second weapon slot
var ability                          # Weapon that goes in the third weapon slot
var opponent         = KinematicBody # The bots' opponent
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

var shielded = false # When true, the bot takes no damage. Used by the 'shield' ability
var immobilized = 0.0 # How long the bot will be unable to move for. Used by the 'snare' secondary


signal game_end # The signal indicate the the arena match is over

#onready var aby_shield    = preload("res://Scenes/aby_shield.tscn") # The shield scene to be instanced
onready var heavy_attack  = preload("res://Scenes/atk_heavy.tscn")  # The heavy scene to be instanced
#onready var quick_attack  = preload("res://Scenes/atk_quick.tscn")  # The quick scene to be instanced
#onready var ranged_attack = preload("res://Scenes/atk_ranged.tscn") # The ranged scene to be instanced
#onready var aby_evade     = preload("res://Scenes/aby_evade.tscn")  # The evade scene to be instanced

func _ready():
	hit_points = max_HP
	#set_weapons(weapon_creator.create_weapon(weapon_creator.W_PRI_SWORD), weapon_creator.create_weapon(weapon_creator.W_SEC_SCYTHE), weapon_creator.create_weapon(weapon_creator.W_ABI_SHIELD))
	pass

# Function to change weapons; is sent weapon scene as a parameter
func set_weapons(new_primary, new_secondary, new_ability):
	if self.get_child_count() > 4:   # Don't remove children if there aren't any
		self.remove_child(primary_weapon)  #queue_free()?
		self.remove_child(secondary_weapon)
		self.remove_child(ability)
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

# Moves the bot in the current specified direction, unless it is immobilized
func move_bot():
	if immobilized <= 0.0:
		move_and_slide(direction.normalized()*movement_speed, UP)

func _process(delta):
	if get_hit_points() <= 0 and opponent.get_hit_points() != 0:
		emit_signal("game_end")
	if immobilized > 0.0:
		immobilized -= delta
