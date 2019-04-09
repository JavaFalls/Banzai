extends ColorRect

onready var head        = get_tree().get_root().get_node("/root/head")
onready var text_field  = get_node('LineEdit')
onready var tag_success = get_node('Success')
onready var tag_error   = get_node('Error')

func open():
	text_field.text = ''
	text_field.grab_focus()

func process_command():
	var text = text_field.text.to_lower()
	text_field.text = ''
	
	match text:
		'hello':
			print_success('Hello to you as well')
		'toggle ids':
			head.show_bot_ids = !head.show_bot_ids
			if head.show_bot_ids:
				print_success('Bot IDs are now shown in place of score in the ranking screen')
			else:
				print_success('Bot IDs are now hidden, ranking screen is back to normal')
		_:
			print_error('I don\'t understand what you\'re saying')

func print_success(text):
	tag_success.text = text
	tag_error.text   = ''

func print_error(text):
	tag_error.text   = text
	tag_success.text = ''

func _on_LineEdit_text_entered(new_text):
	process_command()
