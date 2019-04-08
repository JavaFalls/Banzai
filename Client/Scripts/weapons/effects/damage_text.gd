# Controls the text that appears when a bot gets hurt
# Text floats slowly upwards while fading away
extends Node2D

const RED = Color("ff1c1c")
const GREEN = Color("23ff1c")

var lifetime = 0.75
var speed_y = -150

func _ready():
	$timer.wait_time = lifetime
	$timer.start()

func _process(delta):
	position.y += speed_y * delta
	if $timer.time_left > 0.0:
		modulate.a = $timer.time_left / lifetime
	else:
		modulate.a = 0.0

func set_text(text):
	$text.text = text
func set_color(color):
	$text.modulate = color

func _on_Timer_timeout():
	queue_free()
