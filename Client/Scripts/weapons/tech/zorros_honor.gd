# Zorros Honor
# Multiples the bots stats by 2 times
extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The Constants
#------------------------------------------------------------------------
const DURATION = 5.0 # How long, in seconds, the effect lasts
const BOOST_AMOUNT = 2 # How much to boost stats by

# The variables
#------------------------------------------------------------------------
# Stat variables:
var id
var damage         = 0
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
		# Weapon stats
		var w_pri_stats = weapon_creator.get_weapon_stats(bot.primary_weapon.id)
		var w_sec_stats = weapon_creator.get_weapon_stats(bot.secondary_weapon.id)
		match w_pri_stats["type"]:
			"Ranged":
				bot.primary_weapon.damage *= BOOST_AMOUNT
			"Melee":
				bot.primary_weapon.damage *= BOOST_AMOUNT
			"Trap":
				bot.primary_weapon.damage *= BOOST_AMOUNT
		print(bot.primary_weapon.damage)
		match w_sec_stats["type"]:
			"Ranged":
				bot.secondary_weapon.damage *= BOOST_AMOUNT
			"Melee":
				bot.secondary_weapon.damage *= BOOST_AMOUNT
			"Trap":
				bot.secondary_weapon.damage *= BOOST_AMOUNT
		print(bot.secondary_weapon.damage)
		duration_timer.start()
		# Basic Weapon stuff
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

# Function that is called when the duration ends
func _duration_timer_timeout():
	# Reduce stats BOOST_AMOUNT
	# Bot stats
	bot.scale /= BOOST_AMOUNT
	bot.movement_speed /= BOOST_AMOUNT
	# Weapon stats
	var w_pri_stats = weapon_creator.get_weapon_stats(bot.primary_weapon.id)
	var w_sec_stats = weapon_creator.get_weapon_stats(bot.secondary_weapon.id)
	match w_pri_stats["type"]:
		"Ranged":
			bot.primary_weapon.damage /= BOOST_AMOUNT
		"Melee":
			bot.primary_weapon.damage /= BOOST_AMOUNT
		"Trap":
			bot.primary_weapon.damage /= BOOST_AMOUNT
	match w_sec_stats["type"]:
		"Ranged":
			bot.secondary_weapon.damage /= BOOST_AMOUNT
		"Melee":
			bot.secondary_weapon.damage /= BOOST_AMOUNT
		"Trap":
			bot.secondary_weapon.damage /= BOOST_AMOUNT