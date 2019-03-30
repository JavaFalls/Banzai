extends Container

onready var head = get_tree().get_root().get_node("/root/head")
var fighter_num = 1

# Constants
#-------------------------------------------------
const ICON_SIZE = 16 # Icon size, in pixels. Needed to know how big to make the cooldown rectangle

# Variables
#-------------------------------------------------
var initalized = false # Has anyone initalized us yet?

# Our own timers to keep track of cooldowns
var primary_timer = Timer.new()
var secondary_timer = Timer.new()
var ability_timer = Timer.new()

# Cooldown boxes:
onready var primary_cooldown = get_node("horizontal_container/primary/primary_cooldown")
onready var secondary_cooldown = get_node("horizontal_container/secondary/secondary_cooldown")
onready var ability_cooldown = get_node("horizontal_container/ability/ability_cooldown")

# Functions
#-------------------------------------------------
func _ready():
	primary_timer.one_shot = true
	secondary_timer.one_shot = true
	ability_timer.one_shot = true
	add_child(primary_timer)
	add_child(secondary_timer)
	add_child(ability_timer)

func init(w_pri_ID, w_pri_node,
          w_sec_ID, w_sec_node,
          w_abi_ID, w_abi_node):
	var w_pri_stats = weapon_creator.get_weapon_stats(w_pri_ID)
	var w_sec_stats = weapon_creator.get_weapon_stats(w_sec_ID)
	var w_abi_stats = weapon_creator.get_weapon_stats(w_abi_ID)
	get_node("horizontal_container/primary/primary_icon").texture = w_pri_stats["icon"]
	get_node("horizontal_container/secondary/secondary_icon").texture = w_sec_stats["icon"]
	get_node("horizontal_container/ability/ability_icon").texture = w_abi_stats["icon"]
	primary_timer.wait_time = w_pri_stats["speed"]
	secondary_timer.wait_time = w_sec_stats["speed"]
	ability_timer.wait_time = w_abi_stats["speed"]
	w_pri_node.connect("use", self, "primary_use")
	w_sec_node.connect("use", self, "secondary_use")
	w_abi_node.connect("use", self, "ability_use")
	if (w_sec_ID == weapon_creator.W_SEC_NUKE):
		secondary_timer.start()
	initalized = true

func _process(delta):
	if initalized:
		primary_cooldown.rect_size.x = (primary_timer.time_left / primary_timer.wait_time) * ICON_SIZE
		secondary_cooldown.rect_size.x = (secondary_timer.time_left / secondary_timer.wait_time) * ICON_SIZE
		ability_cooldown.rect_size.x = (ability_timer.time_left / ability_timer.wait_time) * ICON_SIZE

# Signal Responders
#-------------------------------------------------
func primary_use():
	primary_timer.start()
	match fighter_num:
		1:
			head.play_stream(head.s_prim1, (randi()%4)+head.sounds.PRIM1)
		2:
			head.play_stream(head.s_prim2, (randi()%4)+head.sounds.PRIM1)
func secondary_use():
	secondary_timer.start()
	match fighter_num:
		1:
			head.play_stream(head.s_sec1, (randi()%7)+head.sounds.SEC1)
		2:
			head.play_stream(head.s_sec2, (randi()%7)+head.sounds.SEC1)
func ability_use():
	ability_timer.start()
	match fighter_num:
		1:
			head.play_stream(head.s_tech1, (randi()%11)+head.sounds.TECH1)
		2:
			head.play_stream(head.s_tech2, (randi()%11)+head.sounds.TECH1)