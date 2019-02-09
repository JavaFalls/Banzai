extends Path2D

export(String) var text = "text"
export(int, -1, 1000) var length = -1
export(float, 0.0, 1000.0) var duration = 0.0
export(float, 0.0, 1000.0) var delay = 0.0
export(int, 0, 10) onready var transition_type = Tween.TRANS_CUBIC
export(int, 0, 3) onready var ease_type = Tween.EASE_OUT

export(Theme) var theme

onready var texture_node = get_node("PathFollow2D/Button/NinePatchRect")
onready var idle_texture = preload("res://assets/menu/name_choice/button_long.png")
onready var hover_texture = preload("res://assets/menu/name_choice/button_long_selected.png")

func _ready():
	var button = get_node("PathFollow2D/Button")
	button.text = text
	if not length < 0:
		button.rect_size.x = length
	if typeof(theme) != TYPE_NIL:
		button.theme = theme

func slide():
	var tween = Tween.new()
	tween.interpolate_property(get_child(0), ":unit_offset", 0.0, 1.0, duration, transition_type, ease_type, delay)
	add_child(tween)
	tween.start()

func _on_Button_mouse_entered():
	texture_node.set_texture(hover_texture) 

func _on_Button_mouse_exited():
	texture_node.set_texture(idle_texture)
