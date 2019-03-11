#  This scene is instanced by a "subclass" (i.e. "player" or "bot") of the entity scene 
#  using entity's set_weapons() function.  Everything in this scene exists for the purpose
#  of the use() function, which is how this attack is used by the mechs.  This scene may
#  instance many individual traps.

extends Node2D

# Signals
#------------------------------------------------------------------------
signal use # All weapons must have this signal so that cooldowns can be displayed

# The variables
#------------------------------------------------------------------------
# Stat variables:
var id               = -1         # The ID of the weapon. Different traps do different things
var cooldown         = 0.0        # Time for firing cooldown
var damage           = 0          # How much damage each trap does
var lifetime                      # How long a trap will remain active
var trap_sprite                   # The graphic used to represent the trap
var trap_scene                    # The scene to instance when creating traps

# Other variables:
var cooldown_timer = Timer.new() # Timer for firing cooldown
onready var trap_container = get_node("trap_container") # node to hold traps
onready var bot = get_parent() # The bot that is holding the trap

# Functions
#------------------------------------------------------------------------
func _ready():
	cooldown_timer.set_wait_time(cooldown)
	cooldown_timer.set_one_shot(true)
	add_child(cooldown_timer)
	cooldown_timer.stop()

# Function that is called when the sword hits a body
func use():
	# Only shoot if cooldown is finished
	if cooldown_timer.is_stopped():
		# Spawn a trap
		spawn_trap()
		cooldown_timer.start()
		emit_signal("use") # Notify anybody who cares that we did our thing

func spawn_trap():
	var trap = trap_scene.instance()
	trap.id = id
	trap.lifetime = lifetime
	trap.damage = damage
	trap.position = bot.global_position
	trap.bot = bot
	trap.set_sprite(trap_sprite)
	trap_container.add_child(trap)