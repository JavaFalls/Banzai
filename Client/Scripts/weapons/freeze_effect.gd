# Controls a visible block of ice that appears when a target is frozen
extends Node2D

# Variables
var duration = 0.25 # How long the freeze effect lasts
onready var timer = get_node("Timer")

# Functions
func _ready():
	timer.wait_time = duration
	timer.one_shot = false
	timer.start()

func _on_Timer_timeout():
	queue_free()

