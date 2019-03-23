# Charge
# Launch the bot at high speed in the current direction.
# Deals damage if contact is made with opponent
extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The Constants
#------------------------------------------------------------------------
const BOOST_SPEED = 3 # How much to boost movement by

# The variables
#------------------------------------------------------------------------
# Stat variables:
var id
var damage         = 0
var cooldown       = 0.0        # Time for using cooldown

# Other variables:
var cooldown_timer = Timer.new() # Timer for firing cooldown
var charging = false # Whether or not the bot is currently charging
var charge_direction = Vector2() # Direction the charge is in

var charge_effect = preload("res://Scenes/weapons/tech/charge_effect.tscn")

onready var bot = get_parent() # The bot that is holding the ability

# Functions
#------------------------------------------------------------------------
func _ready():
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.stop()

func _process(delta):
	if charging:
		var number_of_collisions = bot.get_slide_count()
		if number_of_collisions > 0:
			var i = 0
			var collision
			while i < number_of_collisions:
				collision = bot.get_slide_collision(i)
				var effect = charge_effect.instance()
				effect.position = collision.position
				bot.get_parent().add_child(effect)
				if collision.collider.is_in_group("damageable"):
					collision.collider.increment_hitpoints(damage)
				i += 1
			bot.modulate.g = 1
			bot.modulate.b = 1
			bot.movement_speed /= BOOST_SPEED
			bot.ignore_movement_controls = false
			charging = false

func _physics_process(delta):
	if charging:
		bot.direction = charge_direction

# Function that is called when the ability is used
func use():
	# Only use if cooldown is finished
	if cooldown_timer.is_stopped():
		# Charge effect
		charging = true
		charge_direction = Vector2(cos(bot.aim_angle),sin(bot.aim_angle))
		print(charge_direction)
		bot.ignore_movement_controls = true
		bot.movement_speed *= BOOST_SPEED
		# Make the bot red for the charge
		bot.modulate.g = 0
		bot.modulate.b = 0
		# Basic Weapon stuff
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing