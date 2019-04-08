extends Control

export(String) var text = ""
export(int, 1, 100) var characters_per_line = 20

onready var start_position = Vector2(int($Panel.rect_size.x/2), -int($Panel.rect_size.y/2))
onready var text_height = $PopupPanel/Label.get_font("font").get_height()
onready var text_line_spacing = $PopupPanel/Label.get_font("font").extra_spacing_bottom

var total_lines = 0

func _ready():
	$Panel/Button.connect("toggled", self, "toggle_info")
	
	var panel = $PopupPanel
	var label = $PopupPanel/Label
	
	total_lines = int(ceil(float(text.length())/float(characters_per_line)))
	var next_line
	for pos in range(0, total_lines*characters_per_line, characters_per_line):
		if pos > 0:
			label.text += "\n"
		next_line = text.substr(pos, characters_per_line)
		label.text += next_line

func _process(delta):
	var panel = $PopupPanel
	var label = $PopupPanel/Label
	
#	label.rect_size.y = total_lines * (text_height + text_line_spacing)
	
	panel.rect_size = label.rect_size
	panel.rect_global_position = $Panel.rect_global_position + start_position - Vector2(int(panel.rect_size.x/2), panel.rect_size.y)
#	label.rect_global_position = panel.rect_global_position
	if (panel.rect_global_position.x + panel.rect_size.x) > 400:
		panel.rect_global_position.x = 400 - panel.rect_size.x
	elif panel.rect_global_position.x < 0:
		panel.rect_global_position.x = 0
	if panel.rect_global_position.y < 0:
		panel.rect_global_position.y = $Panel.rect_global_position.y + $Panel.rect_size.y
	set_process(false)

func toggle_info(button_pressed):
	if button_pressed:
		$PopupPanel.show()
	else:
		$PopupPanel.hide()
