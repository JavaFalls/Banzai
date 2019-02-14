extends "res://Scripts/entity.gd"

onready var game_state = self.get_parent().get_child(1)

var relative_mouse = Vector2()


func _ready():
	pass
	


func _process(delta):
	game_state.set_bot_state(self) # This will be set_bot or set_player depending on if its the player's bot or not
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
	return	
		
