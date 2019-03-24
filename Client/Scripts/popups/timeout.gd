extends Node

onready var timer = $Timer
onready var tween = $Tween
onready var popup = $ColorRect
onready var shade = popup.color.a

signal resumed

func _ready():
	timer.connect("timeout", self, "fade")
	timer.start()

func _input(event):
	if popup.visible and (event is InputEventMouse or event is InputEventKey):
		timer.start()
		unfade()
	elif event is InputEventMouse:
		timer.start()

func fade():
	popup.visible = true
	tween.interpolate_property(
		popup, "color:a",
		0.0, shade, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()
	yield(tween, "tween_completed")
	get_node("ColorRect/timeout_warning").popup()

func unfade():
	tween.interpolate_property(
		popup, "color:a",
		popup.color.a, 0.0, 1.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	tween.start()
	get_node("ColorRect/timeout_warning").hide()
	yield(tween, "tween_completed")
	popup.visible = false
	emit_signal("resumed")
