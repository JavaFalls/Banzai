extends ConfirmationDialog

onready var timer = get_node("Timer")
var normal_text
var time_before

func _ready():
	get_cancel().text = "Whatever"
	connect("about_to_show", self, "timeout", [true])
	timer.connect("timeout", self, "timeout", [false])
	normal_text = dialog_text
	pass

func _process(delta):
	if !timer.is_stopped():
		if int(timer.time_left) < int(time_before):
			time_before = int(timer.time_left)
			dialog_text = normal_text + "\n" + str(time_before + 1)
	pass

func timeout(is_first):
	if is_first:
		timer.start()
		time_before = int(timer.wait_time)
	else:
		get_tree().change_scene("res://Scenes/menu_title.tscn")
	pass
