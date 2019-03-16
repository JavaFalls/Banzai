# Controls the effect(s) that appear during the substitution effect

extends Node2D

# Constants
const SPIN_RATE = PI*8 # How fast, in radians per second, the effect spins

# Variables
var target = Vector2()
var duration = 0 # How long the effect lasts

var movement = Vector2()
onready var timer = get_node("Timer")

# Functions
func _ready():
	movement = (target - position) / duration
	timer.wait_time = duration
	timer.one_shot = false
	timer.start()

func _process(delta):
	position += movement * delta
	rotate(SPIN_RATE * delta)

func _on_Timer_timeout():
	queue_free()

func set_sprite(value):
	get_node("Sprite").texture = value
