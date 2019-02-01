# This "subclass" of entity simulates certain actions that a mech may do
# for the purpose of training against.

extends "res://Scripts/entity.gd"

var relative_direction = Vector2()
var move_random        = true               # Move randomly
var move_aggressive    = false              # Move toward opponent's locatoin
var move_defensive     = false              # Move away from the opponent's location
var attack_primary     = true               # Use the primary attack as often as possible
var attack_secondary   = false              # Use the secondary attack as often as possible
var use_ability        = true               # Use the ability as often as possible
var opponent_position  = Vector2()          # The position of the opponent
var inaccuracy         = 150                # Allowed range of variance from the true target

func _ready():
	set_weapons(ranged_attack, heavy_attack, aby_evade)
	
func _physics_process(delta):
	randomize()
	#print(get_opponent())
	opponent_position = get_opponent().get_position()
	psuedo_mouse = opponent_position + Vector2((randi() % inaccuracy) - (inaccuracy/2), (randi() % inaccuracy) - (inaccuracy/2))
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