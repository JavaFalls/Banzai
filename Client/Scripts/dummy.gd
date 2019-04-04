# This "subclass" of entity simulates certain actions that a mech may do
# for the purpose of training against.

extends "res://Scripts/entity.gd"

var relative_direction = Vector2()
var move_random        = false               # Move randomly
var move_aggressive    = false              # Move toward opponent's locatoin
var move_defensive     = false              # Move away from the opponent's location
var move_square        = false
var attack_primary     = false               # Use the primary attack as often as possible
var attack_secondary   = false              # Use the secondary attack as often as possible
var use_ability        = false               # Use the ability as often as possible
var opponent_position  = Vector2()          # The position of the opponent
var inaccuracy         = 1                # Allowed range of variance from the true target
var psuedo_counter     = 0

onready var t = Timer.new()
onready var game_state = self.get_parent().get_child(1)

func _ready():
	#set_weapons(ranged_attack, heavy_attack, aby_evade)
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	
func _process(delta):
	if t.is_stopped():
		if move_square:
			if direction.x == 0:
				direction.x = 1
			else:
				direction *= -1
		if is_player:
			game_state.set_opponent_state(self)
		else:
			game_state.set_bot_state(self)
		t.start()
		
	
func _physics_process(delta):
	psuedo_primary   = 0
	psuedo_secondary = 0
	psuedo_ability   = 0
	randomize()
	opponent_position = get_opponent().get_position()
	psuedo_mouse = opponent_position + Vector2((randi() % inaccuracy) - (inaccuracy/2), (randi() % inaccuracy) - (inaccuracy/2))
	relative_mouse   = psuedo_mouse - self.get_position()
	aim_angle_old    = aim_angle
	aim_angle = (psuedo_mouse - global_position).angle()
	relative_direction = get_position() - opponent_position
	#direction = Vector2(0,0)
	
	if disabled <= 0.0:
		if attack_primary:
			primary_weapon.use()
			psuedo_primary = 1
		if attack_secondary:
			secondary_weapon.use()
			psuedo_secondary = 1
		if use_ability:
			ability.use()
			psuedo_ability = 1
	
	if not ignore_movement_controls:
		if move_random:
			if randi() % 20 == 0:
				direction.x = (randi() % 3) - 1
				direction.y = (randi() % 3) - 1
		elif move_aggressive:
			direction = (opponent_position - self.get_position())
		elif move_defensive:
			direction = (self.get_position() - opponent_position)
	#psuedo_counter = (psuedo_counter+1) % 4
	if psuedo_counter == 0:
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
#	print("psuedo counter = " , psuedo_counter )
	game_state.set_player_action(self)