# The "superclass" that "player", "bot", and "dummy" are derived from.
# This scene contains the functions that the derived scenes have in common.

extends KinematicBody2D
 
const UP             = Vector2(0,0) # Indicates top-down view

var movement_speed   = 100           # Movement speed of the entity
var hit_points       = 1000000000            # The hit point counter for the fighter
var direction        = Vector2()     # Direction the entity is moving
var primary_weapon   = Vector2()     # Weapon that goes in the first weapon slot
var secondary_weapon = Vector2()     # Weapon that goes in the second weapon slot
var ability          = Vector2()     # Weapon that goes in the third weapon slot
var opponent         = KinematicBody # The bots' opponent
var is_player        = 0        # Is the mech controlled by a player
var psuedo_mouse     = Vector2(0,0)  # This is the players curser position/bot's predicted curser position
var psuedo_primary   = 0             # Is the primary weapon key pressed?
var psuedo_secondary = 0             # Is the secondary weapon key pressed?
var psuedo_ability   = 0             # Is the ability weapon key pressed?
var in_peril         = 0             # Is the mech about to be hit by a projectile?
var aim_angle        = 0

signal game_end # The signal indicate the the arena match is over

onready var aby_shield    = preload("res://Scenes/aby_shield.tscn") # The shield scene to be instanced
onready var heavy_attack  = preload("res://Scenes/atk_heavy.tscn")  # The heavy scene to be instanced
onready var quick_attack  = preload("res://Scenes/atk_quick.tscn")  # The quick scene to be instanced
onready var ranged_attack = preload("res://Scenes/atk_ranged.tscn") # The ranged scene to be instanced
onready var aby_evade     = preload("res://Scenes/aby_evade.tscn")  # The evade scene to be instanced

func _ready():
	set_weapons(ranged_attack, quick_attack, aby_evade)

# Function to change weapons; is sent weapon scene as a parameter
func set_weapons(new_primary, new_secondary, new_ability):
	if self.get_child_count() > 4:   # Don't remove children if there aren't any 
		self.remove_child(primary_weapon)  #queue_free()?
		self.remove_child(secondary_weapon)
		self.remove_child(ability)	
	primary_weapon   = new_primary.instance()
	self.add_child(primary_weapon)
	secondary_weapon = new_secondary.instance()
	self.add_child(secondary_weapon)
	ability          = new_ability.instance()
	self.add_child(ability)
	
func get_hit_points():
	return hit_points
	
func get_trajectory():
	return direction
	
func increment_hitpoints(damage): # this decremements now because we make health go down.
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
	
func _process(delta):
	if get_hit_points() <= 0 and opponent.get_hit_points() != 0:
		emit_signal("game_end")