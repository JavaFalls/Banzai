#  This scene is instanced by a "subclass" (i.e. "player" or "bot") of the entity scene 
#  using entity's set_weapons() function.  Everything in this scene exists for the purpose
#  of the use() function, which is how this ability is used by the bots.  
## This ability temporarily adds a deflector around the bot that halfs damage taken from projectiles and reflects the projectiles back at half damage.

extends Node2D

signal use # All weapons must have this signal so that cooldowns can be displayed

# Constants

# Stat variables
var id
var damage # Unused by this weapon
var cooldown
var deflector_duration = 4.0

# Other variables
var cooldown_timer = Timer.new() # Timer for firing cooldown
var active_timer   = Timer.new() # Timer that controls how long the deflector lasts\
onready var bot = get_parent() # Bot using this ability

func _ready():
	$AnimatedSprite.visible = false
	# Timer setup:
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	self.add_child(cooldown_timer)
	cooldown_timer.stop()
	active_timer.wait_time = deflector_duration
	active_timer.one_shot = true
	self.add_child(active_timer)
	active_timer.connect("timeout", self, "_active_timer_timeout")
	active_timer.stop()

func use():
	if cooldown_timer.is_stopped():
		bot.add_to_group("deflector")
		$AnimatedSprite.visible = true
		$AnimatedSprite.play("default")
		cooldown_timer.start()
		active_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

func _active_timer_timeout():
	bot.remove_from_group("deflector")
	$AnimatedSprite.stop()
	$AnimatedSprite.visible = false
