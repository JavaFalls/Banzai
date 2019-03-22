# This script is used by all scenes that are instanced by trap.gd
# It controls the actual behavior of an individual trap placed on the arena

extends Area2D

# Constants
const SNARE_DURATION = 1.00

# Stat Variables:
var        id       = -1
var        lifetime = 1.0
var        damage   = 0

# Other variables:
var bot # Who planted this trap?
onready var lifetime_timer = Timer.new() # How long until the trap selfdestructs

# Helper scenes
onready var explosion = preload("res://Scenes/weapons/explosion.tscn") # Basic explosion that can be instanced.

func _ready():
	# Setup the timer
	lifetime_timer.set_wait_time(lifetime)
	lifetime_timer.set_one_shot(true)
	add_child(lifetime_timer)
	lifetime_timer.connect("timeout", self, "activate", [null])
	lifetime_timer.start()

func _on_body_entered(body):
	if body.get_instance_id() != bot.get_instance_id() and body.is_in_group("damageable"):
		activate(body)

func activate(target):
	match id:
		weapon_creator.W_SEC_MINE:
			var boom = explosion.instance()
			boom.id = id
			boom.min_radius = 1.0
			boom.max_radius = 3.0
			boom.expansion_rate = 35.0
			boom.lifetime = 0.20
			boom.damage = damage
			boom.position = global_position
			#boom.set_sprite(get_node("Sprite").texture)
			bot.get_parent().add_child(boom)
		weapon_creator.W_SEC_SNARE:
			if (target != null):
				target.immobilized += SNARE_DURATION
	self.queue_free()

func set_sprite(value):
	get_node("Sprite").texture = value