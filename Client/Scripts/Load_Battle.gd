extends ResourcePreloader

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	load_scene("res://Scenes/battle_arena.tscn")
	pass

onready var _progress_bar = get_node("ProgressBar")

# Resource loader
var loader
var max_load_time = 100

func load_scene(path):
	loader = ResourceLoader.load_interactive(path)
	set_process(true)

func _process(delta):
	if loader == null:
		set_process(false)
		return
	
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + max_load_time:
		var err = loader.poll()
		
		if err == ERR_FILE_EOF: # load finished
			var resource = loader.get_resource()
			loader = null
			get_tree().change_scene_to(resource)
			break
		elif err == OK:
			update_progress()
		else: # error during loading
			show_error()
			loader = null
			break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	_progress_bar.set_value(progress)
	print("Loading: ---------------------------------------------------")
	print(progress)