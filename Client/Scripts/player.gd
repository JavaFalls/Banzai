extends "res://Scripts/entity.gd"

var relative_mouse = Vector2()

func _physics_process(delta):
	relative_mouse = get_position() - get_viewport().get_mouse_position()
	direction = Vector2(0,0)
	
	if Input.is_action_pressed("primary_attack"):
		primary_weapon.use() # do a signal here? send self as a parameter?
	#	set_weapons(ranged_attack, heavy_attack, aby_evade)
	if Input.is_action_pressed("secondary_attack"):
		secondary_weapon.use()
	if Input.is_action_pressed("ability"):
		ability.use()
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left"):
		direction.x = 0
	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	if Input.is_action_pressed("ui_down"):
		direction.y = 1
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

	move_and_slide(direction.normalized()*movement_speed, UP)

func get_state():
	var state = PoolStringArray() 
	state.append(self.get_position())
	state.append(self.get_trajectory())
	state.append(get_viewport().get_mouse_position())
	state.append(Input.is_action_pressed("primary_attack"))
	state.append(Input.is_action_pressed("secondary_attack"))
	state.append(Input.is_action_pressed("ui_right"))
	state.append(Input.is_action_pressed("ui_left"))
	state.append(Input.is_action_pressed("ui_up"))
	state.append(Input.is_action_pressed("ui_down"))
	return state
	
