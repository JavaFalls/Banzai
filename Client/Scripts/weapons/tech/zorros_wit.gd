# Zorros Wit
# Makes the bot invisible
extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The Constants
#------------------------------------------------------------------------
const DURATION = 3.0 # How long, in seconds, the effect lasts

# The variables
#------------------------------------------------------------------------
# Stat variables:
var id
var damage         = 0
var cooldown       = 0.0        # Time for using cooldown

# Other variables:
var cooldown_timer = Timer.new() # Timer for firing cooldown
var duration_timer = Timer.new() # Timer that lets us know when the effect ends

var zorros_wit_effect = preload("res://Scenes/weapons/tech/zorros_wit_effect.tscn")

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
		# Modify the bot to be invincible and invisible
		bot.invisible = true
		bot.last_known_location = global_position
		if bot.is_player:
			# Allow the player to contiune seeing their bot
			bot.modulate = Color(1,1,1,0.5)
		else:
			# Make the bot completely invisible
			bot.modulate = Color(1,1,1,0)
		duration_timer.start()
		# Special Effects
		var effect = zorros_wit_effect.instance()
		effect.position = global_position
		bot.get_parent().add_child(effect)
		# Basic Weapon stuff
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

# Function that is called when the duration ends
func _duration_timer_timeout():
	bot.invisible = false
	bot.modulate = Color(1,1,1,1)