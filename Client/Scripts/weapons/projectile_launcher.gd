#  This scene is instanced by a "subclass" (i.e. "player" or "bot") of the entity scene 
#  using entity's set_weapons() function.  Everything in this scene exists for the purpose
#  of the use() function, which is how this attack is used by the mechs.  This scene may
#  instance many projectiles.
## This attack fires a projectile at a target

extends Area2D

# Contants
#------------------------------------------------------------------------
const weapon_creator = preload("res://Scripts/weapons/weapon_creator.gd")

# The variables
#------------------------------------------------------------------------
# Stat variables:
var id               = -1         # ID of the weapon. Some ranged weapons have special behavior
var cooldown         = 0.0        # Time for firing cooldown
var damage           = 0          # How much damage each projectile does
var sprite                        # The graphic used by projectiles
var projectile_speed = 1.0        # How fast, in pixels per second, that a projectile flies
var projectile_scene              # The scene to instance when creating projectiles

# Other variables:
var cooldown_timer = Timer.new() # Timer for firing cooldown
onready var projectile_container = get_node("projectile_container") # node to hold projectiles
onready var bot = get_parent() # The bot that is holding the projectile_launcher

# Functions
#------------------------------------------------------------------------
func _ready():
	cooldown_timer.set_wait_time(cooldown)
	print ("projectile launcher cooldown (in seconds): |" + cooldown + "|")
	cooldown_timer.set_one_shot(true)
	projectile_container.add_child(cooldown_timer)
	cooldown_timer.stop()

# Function that is called when the sword hits a body
func use():
	# Only shoot if cooldown is finished
	if cooldown_timer.is_stopped():
		# Which ranged weapon are we?
		match(id):
			weapon_creator.W_PRI_EXPLODING_SHURIKEN:
				pass
			weapon_creator.W_PRI_SCATTER_BOW:
				pass
			weapon_creator.W_PRI_RUBBER_BOW:
				pass
			weapon_creator.W_PRI_ZORROS_GLARE:
				pass
			_: # Default case (W_PRI_ACID_BOW, W_PRI_PRECISION_BOW)
				bullet = projectile_scene.instance()
				bullet.speed = projectile_speed
				bullet.damage = damage
				bullet.set_sprite(sprite)
				bullet.movement = (bot.psuedo_mouse - bot.global_position).normalized()
				projectile_container.add_child(bullet)
		cooldown_timer.start()