# Zorros Honor
# Multiplies the bots stats by 2
extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The Constants
#------------------------------------------------------------------------
const DURATION = 5.0 # How long, in seconds, the effect lasts
const BOOST_AMOUNT = 2 # How much to boost stats by
const ARMOUR_AMOUNT = 0.5 # How much to boost armour by

# The variables
#------------------------------------------------------------------------
# Stat variables:
var id
var damage         = 0 # unused by this weapon
var cooldown       = 0.0        # Time for using cooldown

# Other variables:
var cooldown_timer = Timer.new() # Timer for firing cooldown
var duration_timer = Timer.new() # Timer that lets us know when the effect ends

#var zorros_honor_effect = preload("res://Scenes/weapons/tech/zorros_honor_effect.tscn")

onready var bot = get_parent() # The bot that is holding the ability

# Functions
#------------------------------------------------------------------------
func _ready():
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.stop()
	duration_timer.wait_time = DURATION
	duration_timer.one_shot = true
	add_child(duration_timer)
	duration_timer.stop()
	duration_timer.connect("timeout", self, "_duration_timer_timeout")

# Function that is called when the ability is used
func use():
	# Only use if cooldown is finished
	if cooldown_timer.is_stopped():
		# Boost stats by times BOOST_AMOUNT
		# Bot stats
		bot.scale *= BOOST_AMOUNT
		bot.movement_speed *= BOOST_AMOUNT
		bot.primary_weapon.damage *= BOOST_AMOUNT
		bot.secondary_weapon.damage *= BOOST_AMOUNT
		bot.armour -= ARMOUR_AMOUNT
		duration_timer.start()
		# Basic Weapon stuff
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

# Function that is called when the duration ends
func _duration_timer_timeout():
	# Reduce stats by BOOST_AMOUNT
	# Bot stats
	bot.scale /= BOOST_AMOUNT
	bot.movement_speed /= BOOST_AMOUNT
	bot.primary_weapon.damage /= BOOST_AMOUNT
	bot.secondary_weapon.damage /= BOOST_AMOUNT
	bot.armour += ARMOUR_AMOUNT