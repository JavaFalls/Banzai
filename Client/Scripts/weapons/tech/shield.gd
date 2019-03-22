#  This scene is instanced by a "subclass" (i.e. "player" or "bot") of the entity scene 
#  using entity's set_weapons() function.  Everything in this scene exists for the purpose
#  of the use() function, which is how this ability is used by the mechs.  
## This ability temporarily adds a shield around the mech that prevents all projectiles from passing through it.

extends Node2D

signal use # All weapons must have this signal so that cooldowns can be displayed

# Constants
const SHIELD_END_DURATION = 0.4 # How long it takes to animate the shield ending

# Stat variables
var id
var cooldown
var shield_duration = 2.0

# Other variables
var cooldown_timer = Timer.new() # Timer for firing cooldown
var active_timer   = Timer.new() # Timer that controls how long the shield last
onready var sprite = get_node("AnimatedSprite")
onready var animation = get_node("AnimationPlayer")
onready var bot = get_parent() # Bot using this ability

func _ready():
	sprite.visible = false
	# Timer setup:
	cooldown_timer.wait_time = cooldown
	cooldown_timer.one_shot = true
	self.add_child(cooldown_timer)
	cooldown_timer.stop()
	active_timer.wait_time = shield_duration
	active_timer.one_shot = true
	self.add_child(active_timer)
	active_timer.stop()

func use():
	if cooldown_timer.is_stopped():
		bot.shielded = true
		sprite.visible = true
		animation.play("shield_start")
		cooldown_timer.start()
		active_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

func _on_AnimationPlayer_animation_finished(anim_name):
	match(anim_name):
		"shield_start":
			animation.play("shield_loop")
		"shield_loop":
			if active_timer.time_left <= SHIELD_END_DURATION:
				animation.play("shield_end")
			else:
				animation.play("shield_loop")
		"shield_end":
			sprite.visible = false
			bot.shielded = false
