# The "subclass" of entity that the player controls and that the 
# neural network trains on.

extends "res://Scripts/entity.gd"
onready var game_state = self.get_parent().get_child(1) #Currently child 1 is game state apparently. this is temporary code it needs to set gamestate automatically to the right child
var relative_mouse = Vector2()

func _process(delta):
	if is_player:
		game_state.set_opponent_state(self)
	else:
		game_state.set_bot_state(self)
#	print("set_player_state")

func _physics_process(delta):
	psuedo_mouse     = get_global_mouse_position()
	relative_mouse   = get_viewport().get_mouse_position() - get_position()
	aim_angle        = atan2(relative_mouse.x, relative_mouse.y) # gives angle in radians
	direction        = Vector2(0,0)
	psuedo_ability   = 0
	psuedo_secondary = 0
	psuedo_primary   = 0
	
	if Input.is_action_pressed("primary_attack"):
		primary_weapon.use() 
		psuedo_primary = 1
	if Input.is_action_pressed("secondary_attack"):
		secondary_weapon.use()
		psuedo_secondary = 1
	if Input.is_action_pressed("ability"):
		ability.use()
		psuedo_ability = 1
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
		
	# Control bot animation
	if (psuedo_mouse.x > get_position().x):
		get_node("animation_bot").face_right()
		if direction.x != 0 || direction.y != 0:
			if (direction.x > 0):
				get_node("animation_bot").start_walking_forward()
			else:
				get_node("animation_bot").start_walking_backward()
		else:
			get_node("animation_bot").reset_animation()
	else:
		get_node("animation_bot").face_left()
		if direction.x != 0 || direction.y != 0:
			if (direction.x > 0):
				get_node("animation_bot").start_walking_backward()
			else:
				get_node("animation_bot").start_walking_forward()
		else:
			get_node("animation_bot").reset_animation()
	
	
	move_and_slide(direction.normalized()*movement_speed, UP)
	get_node("Label").set_text(str(get_hit_points()))