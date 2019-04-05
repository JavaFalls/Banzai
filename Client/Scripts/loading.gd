extends Node

onready var _progress_bar = get_node("ProgressBar")

# Resource loader
var loader
var max_load_time = 100
var loaded = false
var loaded_scene = null

func _ready():
	pass

func load_scene(path):
	loader = ResourceLoader.load_interactive(path)
	get_node("ProgressBar").max_value = loader.get_stage_count()
	set_process(true)

func _physics_process(delta):
	if loaded:
		# ResourceLoader finished loading the scene, now we are letting the scene itself control the loading process
		if _progress_bar.value >= _progress_bar.max_value:
			loaded_scene.visible = true
			get_tree().set_current_scene(loaded_scene)
			self.free()

func _process(delta):
	$spinner.rotate(2*PI*delta)
	
	if not loaded:
		# ResourceLoader needs to load the scene
		if loader == null:
			set_process(false)
			return
		
		var t = OS.get_ticks_msec()
		while OS.get_ticks_msec() < t + max_load_time:
			var err = loader.poll()
	
			if err == ERR_FILE_EOF: # load finished
				var resource = loader.get_resource()
				loader = null
				_progress_bar.max_value = 100
				_progress_bar.set_value(0.0)
				loaded_scene = resource.instance()
				get_tree().get_root().add_child(loaded_scene)
				loaded_scene.visible = false
				loaded = true
				return
			elif err == OK:
				update_progress()
			else: # error during loading
				show_error()
				loader = null
				break

func update_progress():
	var progress = float(loader.get_stage()) / loader.get_stage_count()
	_progress_bar.set_value(loader.get_stage())
	print(progress)
	
	# or update a progress animation?
#	var length = get_node("animation").get_current_animation_length()
	
	# call this on a paused animation. use "true" as the second parameter to force the animation to update
#	get_node("animation").seek(progress * length, true)

# percentage is a value between 0 and 1
func set_progress_bar(percentage):
	_progress_bar.set_value(percentage)
	print(percentage)
