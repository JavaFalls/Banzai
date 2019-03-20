# Clone
# Creates a temporary dummy bot that cannot fire that looks like the original bot
# TODO: Stop the game from breaking if the dummy thing is still alive when the game ends
extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The Constants
#------------------------------------------------------------------------
const DUMMY_LIFETIME = 5 # How long, in seconds, that the dummy will be on the battlefield

# The variables
#------------------------------------------------------------------------
# Stat variables:
var id
var damage         = 0
var cooldown       = 0.0        # Time for using cooldown

# Other variables:
var dummy = null # Instance of the dummy
var cooldown_timer = Timer.new() # Timer for firing cooldown
var dummy_timer = Timer.new() # Timer for the dummy's lifetime

var dummy_scene = preload("res://Scenes/dummy.tscn")

onready var bot = get_parent() # The bot that is holding the ability

# Functions
#------------------------------------------------------------------------
func _ready():
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	add_child(cooldown_timer)
	cooldown_timer.stop()
	dummy_timer.wait_time = DUMMY_LIFETIME
	dummy_timer.one_shot = true
	add_child(dummy_timer)
	dummy_timer.stop()
	dummy_timer.connect("timeout", self, "_dummy_timer_timeout")
	var has_post_end_signal = false
	for a_signal in bot.get_parent().get_signal_list():
		if a_signal["name"] == "post_game":
			has_post_end_signal = true
	if has_post_end_signal:
		print("connected")
		bot.get_parent().connect("post_game", self, "_post_end")

# Function that is called when the ability is used
func use():
	# Only use if cooldown is finished
	if cooldown_timer.is_stopped():
		# Create a dummy at the bots current location
		dummy = dummy_scene.instance()
		dummy.position = global_position
		var dummy_primary = weapon_creator.create_weapon(bot.primary_weapon.id)
		var dummy_secondary = weapon_creator.create_weapon(bot.secondary_weapon.id)
		var dummy_ability = weapon_creator.create_weapon(bot.ability.id)
		dummy.set_weapons(dummy_primary, dummy_secondary, dummy_ability)
		dummy.move_random = true
		dummy.move_aggressive = false
		dummy.move_defensive = false
		dummy.move_square = false
		dummy.attack_primary = false
		dummy.attack_secondary = false
		dummy.use_ability = false
		dummy.opponent = bot.opponent
		bot.get_parent().add_child(dummy)
		dummy.get_node("animation_bot").set_primary_color(bot.get_node("animation_bot").get_primary_color())
		dummy.get_node("animation_bot").set_secondary_color(bot.get_node("animation_bot").get_secondary_color())
		dummy.get_node("animation_bot").set_accent_color(bot.get_node("animation_bot").get_accent_color())
		dummy_timer.start()
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

func _dummy_timer_timeout():
	dummy.queue_free()
	dummy = null

func _post_end():
	print("_post_end()")
	if dummy != null:
		dummy.set_physics_process(false)