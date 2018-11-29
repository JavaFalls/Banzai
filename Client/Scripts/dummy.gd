extends "res://Scripts/entity.gd"

var relative_direction = Vector2()
var move_random        = true
var move_aggressive    = false
var move_defensive     = false
var attack_primary     = true
var attack_secondary   = false
var use_ability        = true
var opponent_position  = Vector2()

func _ready():
	set_weapons(ranged_attack, quick_attack, aby_evade)
	
func _physics_process(delta):
	#print(get_opponent())
	opponent_position = get_opponent().get_position()
	relative_direction = get_position() - opponent_position
	#direction = Vector2(0,0)
	
	if attack_primary:
		primary_weapon.use()
	#	set_weapons(ranged_attack, heavy_attack, aby_evade)
	if attack_secondary:
		secondary_weapon.use()
	if use_ability:
		ability.use()
		
	if move_random:
		if randi() % 20 == 0:
			direction.x = (randi() % 3) - 1
			direction.y = (randi() % 3) - 1
	elif move_aggressive:
		direction = (opponent_position - self.get_position())
	elif move_defensive:
		direction = (self.get_position() - opponent_position)
		
#rotate sprite towards the opponent
	if (abs(relative_direction.x) > abs(relative_direction.y)):
		if relative_direction.x > 0:
			set_rotation_degrees(90)
		else:
			set_rotation_degrees(270)
	else:
		if relative_direction.y > 0:
			set_rotation_degrees(180)
		else:
			set_rotation_degrees(0)

	move_and_slide(direction.normalized()*movement_speed, UP)
	get_node("Label").set_text(str(get_hit_points()))