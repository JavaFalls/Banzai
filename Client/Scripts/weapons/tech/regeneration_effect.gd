# Controls the little bubble(s) that appear during the regen effect

extends Node2D

# Constants
const DURATION = 0.5 # How long the bubble lasts
const ASCEND_RATE = 70 # How fast, in pixels per second, the effect floats upwards
const DRIFT = 5 # How many pixels to the left and right the bubble can drift

# Variables
onready var timer = get_node("Timer")
onready var initial_x = global_position.x # The initial x cordinate the effect had


# Functions
func _ready():
	timer.wait_time = DURATION
	timer.one_shot = false
	timer.start()

func _process(delta):
	position.x = initial_x + (sin(timer.time_left*10) * DRIFT)
	position.y -= ASCEND_RATE * delta

func _on_Timer_timeout():
	queue_free()
