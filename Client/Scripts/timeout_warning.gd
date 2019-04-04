extends Popup

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

onready var label = get_node("Label")
onready var timer = get_node("Timer")

var format_text = (
	"The user has been inactive for too long. Exiting in %02d seconds."
)
var time_before

func _ready():
	label.text = format_text % timer.time_left

	connect("about_to_show", self, "timeout", [true])
	timer.connect("timeout", self, "timeout", [false])
	connect("popup_hide", self, "reset")
	pass

func _process(delta):
	if !timer.is_stopped():
		if int(timer.time_left) < int(time_before):
			time_before = int(timer.time_left)
			label.text = format_text % (time_before + 1)
	pass

func timeout(is_first):
	if is_first:
		timer.start()
		time_before = int(timer.wait_time)
	else:
		head.logout()
	pass

func reset():
	$Timer.stop()
