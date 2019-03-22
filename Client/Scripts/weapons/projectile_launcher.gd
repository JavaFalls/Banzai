#  This scene is instanced by a "subclass" (i.e. "player" or "bot") of the entity scene 
#  using entity's set_weapons() function.  Everything in this scene exists for the purpose
#  of the use() function, which is how this attack is used by the mechs.  This scene may
#  instance many projectiles.
## This attack fires a projectile at a target

extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The variables
#------------------------------------------------------------------------
# Stat variables:
var id               = -1         # ID of the weapon. Some ranged weapons have special behavior
var cooldown         = 0.0        # Time for firing cooldown
var damage           = 0          # How much damage each projectile does
var projectile_sprite             # The graphic used by projectiles
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
	cooldown_timer.set_one_shot(true)
	projectile_container.add_child(cooldown_timer)
	cooldown_timer.stop()

func _process(delta):
	get_node("sprite_container").rotation = bot.aim_angle

# Function that is called when the bot uses the launcher
func use():
	# Only shoot if cooldown is finished
	if cooldown_timer.is_stopped():
		# Which ranged weapon are we?
		match(id):
			weapon_creator.W_PRI_SCATTER_BOW:
				for i in range(3):
					var angle = rand_range(bot.aim_angle - (PI*0.25), bot.aim_angle + (PI*0.25))
					spawn_projectile(Vector2(cos(angle),sin(angle)))
			_: # Default case (W_PRI_ACID_BOW, W_PRI_EXPLODING_SHURIKEN, W_PRI_RUBBER_BOW, W_PRI_PRECISION_BOW, W_PRI_ZORROS_GLARE, W_ABI_FREEZE)
				spawn_projectile(Vector2(cos(bot.aim_angle),sin(bot.aim_angle)))
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

func spawn_projectile(direction_vector):
	var bullet = projectile_scene.instance()
	bullet.id = id
	bullet.speed = projectile_speed
	bullet.damage = damage
	bullet.scale = bot.scale
	bullet.set_sprite(projectile_sprite)
	bullet.movement = direction_vector
	bullet.rotate(bullet.movement.angle())
	bullet.position = get_node("sprite_container/Sprite").global_position
	projectile_container.add_child(bullet)

func set_sprite(value):
	get_node("sprite_container/Sprite").texture = value