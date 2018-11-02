extends KinematicBody2D
 
const UP             = Vector2(0,0) # Indicates top-down view

var movement_speed   =  300         # Movement speed of the entity
var p                = Area2D      # New Projectile
var timer            = Timer.new() # Timer for Firing cooldown
var projectile_delay = .3          # Firing cooldown length
var hit_points       = 0           # How many times the entity has been hit
var direction        = Vector2()   # Direction the entity is moving
var primary_weapon   = Area2D
var secondary_weapon = Area2D
var ability          = Area2D
var s                = Area2D

onready var projectile_container = get_node("projectile_container")   # Where the projectiles are stored
onready var projectile           = preload("res://Scenes/projectile.tscn") # The projectile scene to be instanced
onready var player_node          = get_parent().get_node("player")  # A reference to the player node

onready var aby_shield    = preload("res://Scenes/aby_shield.tscn") # The shield scene to be instanced
onready var heavy_attack  = preload("res://Scenes/atk_heavy.tscn") # The heavy scene to be instanced
onready var quick_attack  = preload("res://Scenes/atk_quick.tscn") # The quick scene to be instanced
onready var ranged_attack = preload("res://Scenes/atk_ranged.tscn") # The ranged scene to be instanced
onready var aby_evade     = preload("res://Scenes/aby_evade.tscn") # The evade scene to be instanced

enum weapon_slot {primary,secondary,ability}
enum weapon {empty,heavy,quick,ranged,evade,shield}


func _ready():
	set_weapons(quick_attack, heavy_attack, aby_evade)
	timer.set_wait_time(projectile_delay)
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.stop()

func shoot(target_position):
	p = projectile.instance()
	projectile_container.add_child(p)
	p.set_gravity_scale(0) # There is no gravity in a top-down game
	p.shoot_at_mouse(target_position)


func restart_timer(delay):
	timer.set_wait_time(delay)
	timer.start()

# Will be sent the weapon scene as a parameter
func set_weapons(new_primary, new_secondary, new_ability):
	self.remove_child(primary_weapon)
	primary_weapon   = new_primary.instance()
	self.add_child(primary_weapon)
	self.remove_child(secondary_weapon)
	secondary_weapon = new_secondary.instance()
	self.add_child(secondary_weapon)
	self.remove_child(ability)
	ability          = new_ability.instance()
	self.add_child(ability)
func get_hit_points():
	return hit_points
	
func get_trajectory():
	return direction