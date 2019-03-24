# The "subclass" of entity that the player controls and that the 
# neural network trains on.

extends "res://Scripts/entity.gd"
onready var game_state = self.get_parent().get_child(1) #Currently child 1 is game state apparently. this is temporary code it needs to set gamestate automatically to the right child
onready var psuedo_counter = 0
func _process(delta):
	#game_state.set_player_action(self)
#	if is_player:
#		game_state.set_opponent_state(self)
#	else:
#		game_state.set_bot_state(self)
	pass

func _physics_process(delta):
	psuedo_mouse     = get_global_mouse_position()
	relative_mouse   = get_viewport().get_mouse_position() - get_position()
	psuedo_ability   = 0
	psuedo_secondary = 0
	psuedo_primary   = 0
	
	if disabled <= 0.0:
		if Input.is_action_pressed("ability"):
			ability.use()
			psuedo_ability = 1
		elif Input.is_action_pressed("secondary_attack"):
			secondary_weapon.use()
			psuedo_secondary = 1
		elif Input.is_action_pressed("primary_attack"):
			primary_weapon.use() 
			psuedo_primary = 1
	if not ignore_movement_controls:
		direction = Vector2(0,0)
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
		
	
	psuedo_counter = (psuedo_counter+1) % 4
	if psuedo_counter == 0:
		aim_angle_old    = aim_angle
		aim_angle        = (psuedo_mouse - global_position).angle() # gives angle in radians
		aim_angle_diff = aim_angle - aim_angle_old
		if abs(aim_angle_diff) > .5:
			aim_angle_diff *= -1
		if aim_angle_diff > 0:
			psuedo_aim_right = 1
		elif aim_angle_diff < 0:
			psuedo_aim_left  = 1
		else:
			psuedo_aim_right = 0
			psuedo_aim_left  = 0
	game_state.set_player_action(self)
	
	get_node("Label").set_text(str(get_hit_points()))