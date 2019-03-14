extends "res://Scripts/entity.gd"

onready var game_state = self.get_parent().get_child(1)


func _ready():
	aim_angle = 0

func _process(delta):
	if is_player:
#		game_state.set_opponent_state(self)
		set_opponent_info()
	else:
#		game_state.set_bot_state(self)
		set_bot_info()


func _physics_process(delta):
	move_bot()
	get_node("Label").set_text("NN" + str(get_hit_points()))

func set_bot_info():
	if game_state.predicted_bot_aim_left == 1:
		aim_angle -= .1*PI
		if aim_angle < -1*PI:
			aim_angle += 2*PI
	if game_state.predicted_bot_aim_right == 1:
		aim_angle += .1*PI
		if aim_angle > PI:
			aim_angle -= 2*PI
#	psuedo_mouse     = game_state.predicted_bot_mouse
	psuedo_mouse     = opponent.get_position()
	relative_mouse   = psuedo_mouse - self.get_position()
#	aim_angle        = atan2(relative_mouse.x, relative_mouse.y) # gives angle in radians
	direction        = game_state.predicted_bot_vector
#	print(game_state.predicted_bot_vector)
#	direction        = Vector2(0,0)
	psuedo_ability       = 0
	psuedo_secondary     = 0
	psuedo_primary       = 0
	game_state.predicted_bot_aim_left = 0
	game_state.predicted_bot_aim_right = 0

	if disabled <= 0.0:
		if game_state.predicted_bot_psuedo_primary:
			primary_weapon.use()
			psuedo_primary = 1
		if game_state.predicted_bot_psuedo_secondary:
			secondary_weapon.use()
			psuedo_secondary = 1
		if game_state.predicted_bot_psuedo_ability:
			ability.use()
			psuedo_ability = 1


	# Control bot animation
	if aim_angle > - (PI*0.5) and aim_angle <= (PI*0.5):
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

func set_opponent_info():
	if game_state.predicted_opponent_aim_left == 1:
		aim_angle -= .1*PI
		if aim_angle < -1*PI:
			aim_angle += 2*PI
	if game_state.predicted_opponent_aim_right == 1:
		aim_angle += .1*PI
		if aim_angle > PI:
			aim_angle -= 2*PI

#	psuedo_mouse     = game_state.predicted_opponent_mouse
	psuedo_mouse     = opponent.get_position()
	relative_mouse   = psuedo_mouse - self.get_position()
#	aim_angle        = atan2(relative_mouse.x, relative_mouse.y) # gives angle in radians
	direction        = game_state.predicted_opponent_vector
#	direction        = Vector2(0,0)
	psuedo_ability       = 0
	psuedo_secondary     = 0
	psuedo_primary       = 0
	game_state.predicted_opponent_aim_left = 0
	game_state.predicted_opponent_aim_right = 0

	if disabled <= 0.0:
		if game_state.predicted_opponent_psuedo_primary:
			primary_weapon.use()
			psuedo_primary = 1
		if game_state.predicted_opponent_psuedo_secondary:
			secondary_weapon.use()
			psuedo_secondary = 1
		if game_state.predicted_opponent_psuedo_ability:
			ability.use()
			psuedo_ability = 1


	# Control bot animation
	if aim_angle > - (PI*0.5) and aim_angle <= (PI*0.5):
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
