extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

onready var _background = get_node("Container/background")
onready var _stats = get_node("stats")

onready var _primary_current = get_node("primary_weapons/HBoxContainer/HBoxContainer/current")
onready var _primary_next = get_node("primary_weapons/HBoxContainer/HBoxContainer/next")
onready var _primary_prev = get_node("primary_weapons/HBoxContainer/HBoxContainer/previous")
onready var _primary_label = get_node("primary_weapons/Label")

onready var _secondary_current = get_node("secondary_weapons/HBoxContainer/HBoxContainer/current")
onready var _secondary_next = get_node("secondary_weapons/HBoxContainer/HBoxContainer/next")
onready var _secondary_prev = get_node("secondary_weapons/HBoxContainer/HBoxContainer/previous")
onready var _secondary_label = get_node("secondary_weapons/Label")

onready var _ability_current = get_node("abilities/HBoxContainer/HBoxContainer/current")
onready var _ability_next = get_node("abilities/HBoxContainer/HBoxContainer/next")
onready var _ability_prev = get_node("abilities/HBoxContainer/HBoxContainer/previous")
onready var _ability_label = get_node("abilities/Label")

onready var bots = head.bots
var current_bot = head.PLAYER

onready var primaries = head.primaries
onready var secondaries = head.secondaries
onready var abilities = head.abilities

var stats = [
	"Attack: ",
	"Armor: ",
	"Range: ",
	"Points: ",
	"Weight: "
]

func _ready():
	get_tree().get_root().connect("size_changed", self, "_resize")
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / head.NORMAL_WIDTH, size.y / head.NORMAL_HEIGHT)
	
	for stat in stats:
		_stats.add_item(stat, null, false)
	pass

# TEST CODE ------------------------------------------------------------------------------#
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		head.save_bots(bots)
	elif Input.is_action_just_pressed("ui_down"):
		bots = head.load_bots()
#-----------------------------------------------------------------------------------------#

func _on_go_button_pressed():
	get_tree().change_scene("res://Scenes/arena_train.tscn")
	pass

func _on_back_button_pressed():
	get_tree().change_scene("res://Scenes/main_menu.tscn")
	pass

func _resize():
	var size = OS.get_window_size()
	_background.scale = Vector2(size.x / head.NORMAL_WIDTH, size.y / head.NORMAL_HEIGHT)
	pass

func move_primaries(direction):
	primaries.set_current(primaries.call(direction))
	
	bots[current_bot].items[head.PRIMARY] = primaries.current()
	
	update_items(head.PRIMARY)
	update_stats()
	pass

func move_secondaries(direction):
	secondaries.set_current(secondaries.call(direction))
	
	bots[current_bot].items[head.SECONDARY] = secondaries.current()
	
	update_items(head.SECONDARY)
	update_stats()
	pass

func move_abilities(direction):	
	abilities.set_current(abilities.call(direction))
	
	bots[current_bot].items[head.ABILITY] = abilities.current()
	
	update_items(head.ABILITY)
	update_stats()
	pass

func update_stats():
	var prim_stats = primaries.current().stats.values()
	var sec_stats = secondaries.current().stats.values()
	var abil_stats = abilities.current().stats.values()
	for i in range(_stats.get_item_count()):
		_stats.set_item_text(i, stats[i] + str(prim_stats[i] + sec_stats[i] + abil_stats[i]))
	pass

func update_items(list):
	match (list):
		head.PRIMARY:
			_primary_current.texture = primaries.current().texture
			_primary_next.texture = primaries.next().texture
			_primary_prev.texture = primaries.prev().texture
			_primary_label.text = "Primary: " + primaries.current().text
		head.SECONDARY:
			_secondary_current.texture = secondaries.current().texture
			_secondary_next.texture = secondaries.next().texture
			_secondary_prev.texture = secondaries.prev().texture
			_secondary_label.text = "Secondary: " + secondaries.current().text
		head.ABILITY:
			_ability_current.texture = abilities.current().texture
			_ability_next.texture = abilities.next().texture
			_ability_prev.texture = abilities.prev().texture
			_ability_label.text = "Ability: " + abilities.current().text
	pass

func switch_bot(bot):
	current_bot = bot
	var items = bots[current_bot].items
	primaries.set_current(items[head.PRIMARY])
	secondaries.set_current(items[head.SECONDARY])
	abilities.set_current(items[head.ABILITY])
	update_items(head.PRIMARY)
	update_items(head.SECONDARY)
	update_items(head.ABILITY)
	update_stats()
	pass
