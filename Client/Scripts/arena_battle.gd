extends Node2D

onready var _camera = get_node("Camera2D")

onready var _bot1 = get_node("bot1")
onready var _bot2 = get_node("bot2")

var speed = 310
var move1 = Vector2()
var move2 = Vector2()

var center = Vector2()
export(Vector2) var min_zoom = Vector2(1, 1)
export(Vector2) var max_zoom = Vector2(2, 2)
export(float) var min_distance = 600
export(float) var max_distance = 2000

func _ready():
	_camera.make_current()
	pass

func _process(delta):
	move_camera()
	pass

func _physics_process(delta):
	get_input()
	_bot1.move_and_slide(move1)
	_bot2.move_and_slide(move2)
	pass

func _enter_tree():
#	_camera.make_current()
	pass

func _exit_tree():
	_camera.clear_current()
	pass

func get_input():
	move1 = Vector2(0, 0)
	move2 = Vector2(0, 0)
	
	if Input.is_key_pressed(KEY_LEFT):
		move1.x -= speed
	if Input.is_key_pressed(KEY_RIGHT):
		move1.x += speed
	if Input.is_key_pressed(KEY_UP):
		move1.y -= speed
	if Input.is_key_pressed(KEY_DOWN):
		move1.y += speed
	
	if Input.is_key_pressed(KEY_A):
		move2.x -= speed
	if Input.is_key_pressed(KEY_D):
		move2.x += speed
	if Input.is_key_pressed(KEY_W):
		move2.y -= speed
	if Input.is_key_pressed(KEY_S):
		move2.y += speed
	pass

func move_camera():
	center = Vector2(
		lerp(_bot1.get_global_position().x, _bot2.get_global_position().x, 0.5),
		lerp(_bot1.get_global_position().y, _bot2.get_global_position().y, 0.5)
	)
	_camera.translate(center - _camera.get_global_position())
	
	var distance = _bot1.get_global_position().distance_to(_bot2.get_global_position())
	var dist_perc = 0.0
	if distance > min_distance:
		dist_perc = (distance - min_distance) / max_distance
	var new_zoom = min_zoom.linear_interpolate(max_zoom, (dist_perc))
	_camera.zoom = new_zoom
	pass
