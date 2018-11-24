extends Node

onready var _progress_bar = get_node("ProgressBar")

# Resource loader
var loader
var max_load_time = 100

func _ready():
	pass

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
	print(progress)
	
	# or update a progress animation?
#	var length = get_node("animation").get_current_animation_length()
	
	# call this on a paused animation. use "true" as the second parameter to force the animation to update
#	get_node("animation").seek(progress * length, true)
