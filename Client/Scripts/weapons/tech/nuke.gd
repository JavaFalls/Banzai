# Nuke.
# Blows things up
extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The Constants
#------------------------------------------------------------------------

# The variables
#------------------------------------------------------------------------
# Stat variables:
var cooldown       = 0.0        # Time for using cooldown

# Other variables:
var cooldown_timer = Timer.new() # Timer for firing cooldown
var min_coordinate = Vector2(21,44) # The top left corner of the area that is valid for teleportation
var max_coordinate = Vector2(385,225) # The bottom right corner of the area that is valid for teleportation

var teleport_effect = preload("res://Scenes/weapons/tech/teleport_effect.tscn")

onready var bot = get_parent() # The bot that is holding the ability

# Functions
#------------------------------------------------------------------------
func _ready():
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.stop()

# Function that is called when the ability is used
func use():
	# Only use if cooldown is finished
	if cooldown_timer.is_stopped():
		# Create a teleport_effect at the bots current location
		var portal_entrance = teleport_effect.instance()
		portal_entrance.position = bot.global_position
		bot.get_parent().add_child(portal_entrance)
		# Teleport the bot
		bot.position = Vector2(rand_range(min_coordinate.x, max_coordinate.x), rand_range(min_coordinate.y, max_coordinate.y))
		# Create a teleport_effect at the bots new location
		var portal_exit = teleport_effect.instance()
		portal_exit.position = bot.global_position
		bot.get_parent().add_child(portal_exit)
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing