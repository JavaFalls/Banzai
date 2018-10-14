extends Node2D

onready var _camera = get_node("Camera2D")

onready var _sprite1 = get_node("Sprite")
onready var _sprite2 = get_node("Sprite2")

var speed = 5
var move1 = Vector2()
var move2 = Vector2()

var center = Vector2()

func _ready():
	_camera.make_current()
	pass

func _process(delta):
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
	_sprite1.translate(move1)
	
	if Input.is_key_pressed(KEY_A):
		move2.x -= speed
	if Input.is_key_pressed(KEY_D):
		move2.x += speed
	if Input.is_key_pressed(KEY_W):
		move2.y -= speed
	if Input.is_key_pressed(KEY_S):
		move2.y += speed
	_sprite2.translate(move2)
	
	move_camera()
	pass

func _enter_tree():
#	_camera.make_current()
	pass

func _exit_tree():
	_camera.clear_current()
	pass

func move_camera():
	center = Vector2(
		lerp(_sprite1.get_global_position().x, _sprite2.get_global_position().x, 0.5),
		lerp(_sprite1.get_global_position().y, _sprite2.get_global_position().y, 0.5)
	)
	
	_camera.translate(Vector2(
		(center - _camera.get_global_position())
	))
	pass
