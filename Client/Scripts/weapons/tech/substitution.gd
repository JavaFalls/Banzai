# Trades positions with the opponent
extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The Constants
#------------------------------------------------------------------------

# The variables
#------------------------------------------------------------------------
# Stat variables:
var id
var cooldown = 0.0 # Time for using cooldown
var duration       # How long it takes for the substitution to actually take place

# Other variables:
var cooldown_timer = Timer.new() # Timer for firing cooldown
var trigger_timer = Timer.new() # Timer to control how long to wait between trigger substitution and actually do the substitute

var source_position      = Vector2()
var destination_position = Vector2()
var renable_collisions   = -1

var substitution_effect = preload("res://Scenes/weapons/tech/substitution_effect.tscn")
var substitution_destination_sprite = preload("res://Assets/weapons/substitute_destination.png")
var substitution_source_sprite      = preload("res://Assets/weapons/substitute_source.png")

onready var bot = get_parent() # The bot that is holding the ability

# Functions
#------------------------------------------------------------------------
func _ready():
	duration = cooldown * 0.5
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.stop()
	trigger_timer.wait_time = duration
	trigger_timer.one_shot = true
	add_child(trigger_timer)
	trigger_timer.connect("timeout", self, "_trigger_timer_timeout")
	trigger_timer.stop()

func _process(delta):
	if renable_collisions > 0:
		renable_collisions -= 1
	elif renable_collisions == 0:
		# We have to wait until the frame after we move the bots to enable collisions
		bot.remove_collision_exception_with(bot.opponent)
		bot.opponent.remove_collision_exception_with(bot)
		renable_collisions = -1

# Function that is called when the ability is used
func use():
	# Only use if cooldown is finished
	if cooldown_timer.is_stopped():
		# Create a substitution_effect at source_position
		var substitution_source = substitution_effect.instance()
		substitution_source.position = bot.get_position()
		substitution_source.target = bot.opponent
		substitution_source.set_sprite(substitution_source_sprite)
		substitution_source.duration = duration
		bot.get_parent().add_child(substitution_source)
		# Create a substitution_effect at destination_position
		var substitution_destination = substitution_effect.instance()
		substitution_destination.position = bot.opponent.get_position()
		substitution_destination.target = bot
		substitution_destination.set_sprite(substitution_destination_sprite)
		substitution_destination.duration = duration
		bot.get_parent().add_child(substitution_destination)
		
		# Start the timer. We'll move the bots once the graphic effects reach their targets
		trigger_timer.start()
		
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

func _trigger_timer_timeout():
	# Stop a collision from being detected when we move the bots
	bot.add_collision_exception_with(bot.opponent)
	bot.opponent.add_collision_exception_with(bot)
	# Swap the bots
	var old_position = bot.position
	bot.position = bot.opponent.position
	bot.opponent.position = old_position
	#bot.position = destination_position
	#bot.opponent.position = source_position
	# Wait until next frame to renable collisions
	renable_collisions = 1