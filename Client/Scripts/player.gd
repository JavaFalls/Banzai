# The "subclass" of entity that the player controls and that the 
# neural network trains on.

extends "res://Scripts/entity.gd"
onready var game_state = self.get_parent().get_child(1) #Currently child 1 is game state apparently. this is temporary code it needs to set gamestate automatically to the right child
var relative_mouse = Vector2()

func _physics_process(delta):
	psuedo_mouse     = get_global_mouse_position()
	relative_mouse   = get_position() - get_viewport().get_mouse_position()
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
	#print(self.get_parent().get_children())
	
	if is_player:
		game_state.set_player_state(self)
	else:
		game_state.set_bot_state(self)
	move_and_slide(direction.normalized()*movement_speed, UP)
	get_node("Label").set_text(str(get_hit_points()))