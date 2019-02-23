extends "res://Scripts/entity.gd"

onready var game_state = self.get_parent().get_child(1)

var relative_mouse = Vector2()


func _ready():
	pass
	


func _process(delta):
	if is_player:
		game_state.set_player_state(self)
	else:
		game_state.set_bot_state(self)
	return

func _physics_process(delta):
	psuedo_mouse     = game_state.predicted_bot_mouse
	relative_mouse   = self.get_position() - psuedo_mouse
	direction        = game_state.predicted_bot_vector
	psuedo_ability       = 0
	psuedo_secondary     = 0
	psuedo_primary       = 0
	
	if game_state.predicted_bot_psuedo_primary:
		primary_weapon.use() 
		psuedo_primary = 1
	if game_state.predicted_bot_psuedo_secondary:
		secondary_weapon.use()
		psuedo_secondary = 1
	if game_state.predicted_bot_psuedo_ability:
		ability.use()
		psuedo_ability = 1
	
	#rotate sprite towards the mouse curser
	if relative_mouse.x > 0:
		get_node("animation_bot").face_right()
	else:
		get_node("animation_bot").face_left()
	
	# Control bot animation
	if direction.x != 0 || direction.y != 0:
		if (direction.x > 0 && relative_mouse.x > 0) || (direction.x < 0 && relative_mouse.y < 0):
			get_node("animation_bot").start_walking_forward()
		else:
			get_node("animation_bot").start_walking_backward()
	else:
		get_node("animation_bot").reset_animation()

	move_and_slide(direction.normalized()*movement_speed, UP)
	return	
		
