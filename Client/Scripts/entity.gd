extends KinematicBody2D
 
const UP             = Vector2(0,0) # Indicates top-down view

var movement_speed   =  300         # Movement speed of the entity
var p                = Area2D      # New Projectile
var timer            = Timer.new() # Timer for Firing cooldown
var projectile_delay = .3          # Firing cooldown length
var hit_points       = 0           # How many times the entity has been hit
var direction        = Vector2()   # Direction the entity is moving
var primary_weapon   = Vector2()
var secondary_weapon = Vector2()
var ability          = Vector2()
var s                = Area2D
var hitpoints        = 0           # The hitpoint counter for the fighter

onready var player_node          = get_parent().get_node("player")  # A reference to the player node

onready var aby_shield    = preload("res://Scenes/aby_shield.tscn") # The shield scene to be instanced
onready var heavy_attack  = preload("res://Scenes/atk_heavy.tscn") # The heavy scene to be instanced
onready var quick_attack  = preload("res://Scenes/atk_quick.tscn") # The quick scene to be instanced
onready var ranged_attack = preload("res://Scenes/atk_ranged.tscn") # The ranged scene to be instanced
onready var aby_evade     = preload("res://Scenes/aby_evade.tscn") # The evade scene to be instanced

func _ready():
	set_weapons(ranged_attack, heavy_attack, aby_evade)

# Will be sent the weapon scene as a parameter
func set_weapons(new_primary, new_secondary, new_ability):
	if self.get_child_count() > 3:   # Don't remove children if there aren't any 
		self.remove_child(primary_weapon)
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
	
func increment_hitpoints(inc_num):
	hit_points += inc_num
	print(hit_points)