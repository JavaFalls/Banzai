# Controls the portal(s) that appear during the teleport effect

extends Node2D

# Constants
const DURATION = 0.25 # How long the portal lasts
const SPIN_RATE = PI*2 # How fast, in radians per second, the effect spins

# Variables
onready var timer = get_node("Timer")

# Functions
func _ready():
	timer.wait_time = DURATION
	timer.one_shot = false
	timer.start()

func _process(delta):
	rotate(SPIN_RATE * delta)

func _on_Timer_timeout():
	queue_free()
