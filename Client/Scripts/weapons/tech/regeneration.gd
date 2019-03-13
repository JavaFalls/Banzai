# Regenerates the host bot by the specified amount
extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The Constants
#------------------------------------------------------------------------
const TOTAL_HEAL      = 10  # The total amount of HP to regenerate
const AMT_PER_CYCLE   = 1   # How much HP to heal each cycle
const DURATION        = 2.0 # How long the heal lasts
const CYCLE_FREQUENCY = DURATION / (TOTAL_HEAL * AMT_PER_CYCLE) # How often to heal the bot by AMT_PER_CYCLE

# The variables
#------------------------------------------------------------------------
# Stat variables:
var cooldown         = 0.0        # Time for using cooldown

# Other variables:
var cooldown_timer = Timer.new() # Timer for firing cooldown
var cycle_timer    = Timer.new() # Timer for healing the bot periodically
var amt_healed = 0         # How much healing has already been done

var regeneration_effect = preload("res://Scenes/weapons/tech/regeneration_effect.tscn")

onready var bot = get_parent() # The bot that is holding the ability

# Functions
#------------------------------------------------------------------------
func _ready():
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.stop()
	cycle_timer.wait_time = CYCLE_FREQUENCY
	cycle_timer.one_shot = false
	add_child(cycle_timer)
	cycle_timer.stop()
	cycle_timer.connect("timeout", self, "cycle_timer_timeout")

# Function that is called when the ability is used
func use():
	# Only use if cooldown is finished
	if cooldown_timer.is_stopped():
		amt_healed = 0
		cycle_timer.start()
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

func cycle_timer_timeout():
	# Effect
	var regen_bubble = regeneration_effect.instance()
	regen_bubble.position = global_position
	bot.get_parent().add_child(regen_bubble)
	# Actual Heal
	bot.hit_points += 1
	amt_healed += 1
	if bot.hit_points > bot.max_HP:
		bot.hit_points = bot.max_HP
	if amt_healed >= TOTAL_HEAL:
		cycle_timer.stop()