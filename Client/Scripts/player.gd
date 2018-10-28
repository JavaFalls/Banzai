extends "res://Scripts/entity.gd"

var relative_mouse = Vector2()

func _physics_process(delta):
	relative_mouse = get_position() - get_viewport().get_mouse_position()
	direction = Vector2(0,0)
	
	if Input.is_action_pressed("primary_attack"):
		if timer.is_stopped():
			shoot(self.global_position)
			restart_timer(projectile_delay)
#		pimary_attack.use()
	if Input.is_action_pressed("secondary_attack"):
		if timer.is_stopped():
			shoot(self.global_position)
			restart_timer(projectile_delay)
	if Input.is_action_pressed("ui_right"):
		direction.x = MOVEMENT_SPEED
	if Input.is_action_pressed("ui_left"):
		direction.x = -MOVEMENT_SPEED
	if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
		direction.x = 0
	
	if Input.is_action_pressed("ui_up"):
		direction.y = -MOVEMENT_SPEED
	if Input.is_action_pressed("ui_down"):
		direction.y = MOVEMENT_SPEED
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

func get_state():
	var state = PoolStringArray() 
	state.append(self.get_position())
	state.append(self.get_trajectory())
	state.append(get_viewport().get_mouse_position())
