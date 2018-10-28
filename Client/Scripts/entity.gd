extends KinematicBody2D
 
const UP             = Vector2(0,0) # Indicates top-down view
const MOVEMENT_SPEED =  300         # Movement speed of the entity

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
onready var shield               = preload("res://Scenes/aby_shield.tscn")
#onready var heavy_attack  = preload("res://heavy.tscn") # The heavy scene to be instanced
#onready var quick_attack  = preload("res://quick.tscn") # The quick scene to be instanced
#onready var ranged_attack = preload("res://ranged.tscn") # The ranged scene to be instanced
#onready var evade         = preload("res://evade.tscn") # The evade scene to be instanced
#onready var shield        = preload("res://shield.tscn") # The shield scene to be instanced

enum weapon_slot {primary,secondary,ability}
enum weapon {empty,heavy,quick,ranged,evade,shield}


func _ready():
#	var primary_weapon   = quick_attack
#	var secondary_weapon = heavy_attack
#	var ability          = evade
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
	primary_weapon   = new_primary
	self.add_child(primary_weapon.instance())
	self.remove_child(secondary_weapon)
	secondary_weapon = new_secondary
	self.add_child(secondary_weapon.instance())
	self.remove_child(ability)
	ability          = new_ability
	self.add_child(ability.instance())
func get_hit_points():
	return hit_points
	
func get_tragectory():
	return direction