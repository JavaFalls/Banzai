extends KinematicBody2D

const UP = Vector2(0,0)
const SPEED =  300
var direction = Vector2()
onready var player_node = get_node("player")
var this_node = Node2D
var p = Area2D
var ev = InputEventAction.new()
# or #export (PackedScene) var projectile
onready var projectile_container = get_node("player_projectiles")
onready var projectile = preload("res://projectile.tscn")
#onready var ZZ = get_node("ZZ")

func shoot():
	
	#ZZ.add_child(projectile.instance())
	#var p = projectile.instance()
	#projectile_container.add_child(p)
	#p.start_at(get_viewport().get_mouse_position(), get_position())
	p = projectile.instance()
	projectile_container.add_child(p)
	p.set_gravity_scale(0) # There is no gravity in a top-down game
	p.shoot_at_mouse(self.global_position)

#func _ready():
	#player_node = get_node("player")
#	this_node = get_node("entity")


#func _physics_process(delta):
#	direction = move_and_slide(direction, UP)
#	direction = Vector2(0,0)
#	pass