extends Camera2D

onready var _player = get_node("../player")
onready var _player2 = get_node("../player2")

var center = Vector2()
export(Vector2) var min_zoom = Vector2(1, 1)
export(Vector2) var max_zoom = Vector2(2, 2)
export(float) var min_distance = 600
export(float) var max_distance = 2000

func _ready():
	print(_player)
	pass

func _process(delta):
	move_camera()
	pass

func _exit_tree():
	clear_current()
	pass

func move_camera():
	center = Vector2(
		lerp(_player.get_global_position().x, _player2.get_global_position().x, 0.5),
		lerp(_player.get_global_position().y, _player2.get_global_position().y, 0.5)
	)
	translate(center - get_global_position())
	
	var distance = _player.get_global_position().distance_to(_player2.get_global_position())
	var dist_perc = 0.0
	if distance > min_distance:
		dist_perc = (distance - min_distance) / max_distance
	var new_zoom = min_zoom.linear_interpolate(max_zoom, (dist_perc))
	zoom = new_zoom
	pass
