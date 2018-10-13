extends "res://entity.gd"
var relative_mouse = Vector2()

func _physics_process(delta):
	relative_mouse = get_position() - get_viewport().get_mouse_position()
	direction = Vector2(0,0)
	
	if Input.is_action_pressed("primary_attack"):
		shoot()
		print ("shoot")
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
		
#rotate sprite towards the mouse curser
	if (abs(relative_mouse.x) > abs(relative_mouse.y)):
		if relative_mouse.x > 0:
			set_rotation_degrees(90)
		else:
			set_rotation_degrees(270)
	else:
		if relative_mouse.y > 0:
			set_rotation_degrees(180)
		else:
			set_rotation_degrees(0)


	direction = move_and_slide(direction, UP)

	