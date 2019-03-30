# Nuke.
# Blows things up
extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The Constants
#------------------------------------------------------------------------
const FIRING_DISTANCE = 200 # How far, in pixels, the nuke travels from the bot
const DISABLE_TIME = 1.0 # How long to disable and immoblize the bot after launching a nuke
# Max and min coordinates for the Nuke's target
const MAX_TARGET_COORDINATE = Vector2(425.0, 200.0)
const MIN_TARGET_COORDINATE = Vector2(0.0, 0.0)

# The variables
#------------------------------------------------------------------------
# Stat variables:
var id
var damage         = 0
var cooldown       = 0.0        # Time for using cooldown

# Other variables:
var cooldown_timer = Timer.new() # Timer for firing cooldown

var nuke_missile = preload("res://Scenes/weapons/tech/nuke_missile.tscn")

onready var bot = get_parent() # The bot that is holding the ability

# Functions
#------------------------------------------------------------------------
func _ready():
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.start() # NUKE is the only weapon that starts on cooldown

# Function that is called when the ability is used
func use():
	# Only use if cooldown is finished
	if cooldown_timer.is_stopped():
		# Create a teleport_effect at the bots current location
		var missile = nuke_missile.instance()
		missile.damage = damage
		missile.position = global_position
		missile.scale = bot.scale
		missile.target = (Vector2(cos(bot.aim_angle),sin(bot.aim_angle)) * FIRING_DISTANCE) + global_position
		if missile.target.x > MAX_TARGET_COORDINATE.x:
			missile.target.x = MAX_TARGET_COORDINATE.x
		elif missile.target.x < MIN_TARGET_COORDINATE.x:
			missile.target.x = MIN_TARGET_COORDINATE.x
		if missile.target.y > MAX_TARGET_COORDINATE.y:
			missile.target.y = MAX_TARGET_COORDINATE.y
		elif missile.target.y < MIN_TARGET_COORDINATE.y:
			missile.target.y = MIN_TARGET_COORDINATE.y
		bot.get_parent().add_child(missile)
		bot.disabled += DISABLE_TIME
		bot.immobilized += DISABLE_TIME
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing