# This scene is a special case of the projectile_launcher scene. Used to control the secret Zorro's Glare weapon
# Zorro's Glare fires a single laser in the direction the mech is aiming for a specified time.

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
var duration_timer = Timer.new() # Timer to control how long to fire the laser at a time
var cooldown_timer = Timer.new() # Timer for firing cooldown
var the_laser = null # Variable to hold an instance of the laser in
onready var bot = get_parent() # The bot that is holding this Zorro's Glare

# Functions
#------------------------------------------------------------------------
func _ready():
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.stop()
	duration_timer.wait_time = cooldown * 0.5
	duration_timer.one_shot = true
	add_child(duration_timer)
	duration_timer.stop()
	duration_timer.connect("timeout", self, "_duration_timer_timeout")

func _process(delta):
	# By setting the rotation of the sprite_container, we also change the rotation of the laser
	get_node("sprite_container").rotation = bot.aim_angle

# Function that is called when the bot uses the launcher
func use():
	# Only shoot if cooldown is finished
	if cooldown_timer.is_stopped():
		the_laser = spawn_projectile()
		duration_timer.start()
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

func spawn_projectile():
	var laser = projectile_scene.instance()
	laser.id = id
	laser.projectile_owner = bot
	laser.zorros_glare = self
	laser.set_sprite(projectile_sprite)
	laser.position = get_node("sprite_container/Sprite").position
	get_node("sprite_container").add_child(laser)
	return laser

func set_sprite(value):
	get_node("sprite_container/Sprite").texture = value

# Signal Responders
#------------------------------------------------------------------------
func _duration_timer_timeout():
	the_laser.queue_free()
	the_laser = null