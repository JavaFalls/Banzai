## This scene is no longer used in favor of "battle_arena" (name subject to change)
extends Node2D

onready var _camera = get_node("battle_camera")

onready var _player = get_node("player")
onready var _player2 = get_node("player2")

var speed = 310
var move1 = Vector2()
var move2 = Vector2()

func _ready():
	_camera.make_current()
	pass

func _process(delta):
	pass

func _physics_process(delta):
	get_input()
	_player.move_and_slide(move1)
	_player2.move_and_slide(move2)
	pass

func _enter_tree():
#	_camera.make_current()
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
