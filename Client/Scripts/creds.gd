extends VideoPlayer

var video = get_child(0)

func _ready():
	if(Menu_audio.menu_audio.playing):
		Menu_audio.menu_audio.stop()


func _input(event):
	if event.is_action_pressed("exit_arena"):
		exit()
	
""" ABANDONED CODE

	var time = get_node("Timer")
	var active = false
	time.set_one_shot(true)
	
	if event.is_action_pressed("exit_arena"):
		if (time.is_stopped() and active):
			exit()
		elif (time.is_stopped()):
			time.wait_time = 3
			time.start()
			active = true
	
	elif event.is_action_released("exit_arena"):
		time.stop()
		active = false
"""

func exit():
	get_tree().change_scene("res://Scenes/main_menu.tscn")