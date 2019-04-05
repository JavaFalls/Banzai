extends Node2D

var speed
var words
var size
var theme = preload("res://themes/text_dpcomic.tres")
var color = Color("#22ffffff")

func _ready():
	$label.text = ""
	
	speed = randi()%30 + 10
	if randi()%2 == 0:
		speed = -speed
	words = randi()%3 + 8
	for w in range(words):
		size = randi()%10 + 3
		for s in range(size):
			$label.text += str(randi()%2)
		$label.text += "  "
	
	$label.rect_global_position.x -= 10
	var label1 = Label.new()
	var label2 = Label.new()
	label1.text = $label.text
	label2.text = $label.text
	label1.theme = theme
	label2.theme = theme
	label1.modulate = color
	label2.modulate = color
	add_child(label1)
	add_child(label2)
	label1.rect_global_position = $label.rect_global_position + Vector2($label.rect_size.x, 0)
	label2.rect_global_position = label1.rect_global_position + Vector2(label1.rect_size.x, 0)

func _process(delta):
	for label in get_children():
		global_position.x += speed * delta
	if speed < 0:
		if (get_child(1).rect_global_position.x + get_child(1).rect_size.x/2) < 200:
			get_child(0).queue_free()
			var label = Label.new()
			label.text = get_child(1).text
			label.theme = theme
			label.modulate = color
			add_child(label)
			label.rect_global_position.x = get_child(1).rect_global_position.x + get_child(1).rect_size.x
	else:
		if (get_child(1).rect_global_position.x + get_child(1).rect_size.x/2) > 200:
			get_child(2).queue_free()
			var label = Label.new()
			label.text = get_child(1).text
			label.theme = theme
			label.modulate = color
			add_child(label)
			label.rect_global_position.x = get_child(0).rect_global_position.x - get_child(0).rect_size.x
			move_child(label, 0)
