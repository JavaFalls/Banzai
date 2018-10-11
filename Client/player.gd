extends "res://entity.gd"

func _physics_process(delta):
	direction = Vector2(0,0)
	if Input.is_action_pressed("ui_right"):
		direction.x = SPEED
	if Input.is_action_pressed("ui_left"):
		direction.x = -SPEED
	if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
		direction.x = 0
	
	if Input.is_action_pressed("ui_up"):
		direction.y = -SPEED
	if Input.is_action_pressed("ui_down"):
		direction.y = SPEED
	if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
		direction.y = 0

	direction = move_and_slide(direction, UP)
	pass