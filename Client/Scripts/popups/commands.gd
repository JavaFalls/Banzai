extends ColorRect

onready var head        = get_tree().get_root().get_node("/root/head")
onready var text_field  = get_node('LineEdit')
onready var tag_success = get_node('Success')
onready var tag_error   = get_node('Error')
onready var timer       = get_node('Timer')

func open():
	tag_success.text = ''
	tag_error.text = ''
	text_field.text = ''
	text_field.grab_focus()

func process_command():
	var text = text_field.text
	var atext
	text_field.text = ''
	
	if text.begins_with(':'):
		text = text.substr(1, text.length())
		atext = text.split(' ', false)
		if atext.size() > 0:
			match atext[0]:
				'steal_bot':
					if atext.size() >= 2:
						if head.DB.change_bot_owner(int(atext[1]), head.player_ID):
							refresh_bots()
							print_success('Congratulations, you now own bot ' + str(atext[1]))
						else:
							print_error('Whoops, didn\'t see that one coming')
					else:
						print_error('Whoa, Whoa, Whoa, Hold up . . .')
						
				'tid':
					head.show_bot_ids = !head.show_bot_ids
					if head.show_bot_ids:
						print_success('Bot IDs are now shown in place of score in the ranking screen')
					else:
						print_success('Bot IDs are now hidden, ranking screen is back to normal')
						
				'change_name':
					if atext.size() >= 2:
						var bot = parse_json(head.DB.get_bot(head.bot_ID))["data"][0]
						var name = ''
						var index = 1
						var size = atext.size()
						
						while index < size:
							if index >= 2:
								name += ' '
							name = name + atext[index]
							index +=1
							
						bot["name"] = name
						if head.DB.update_bot(
							head.bot_ID,
							[ bot["player_ID_FK"],
							  bot["model_ID_FK"],
							  bot["ranking"],
							  bot["primary_weapon"],
							  bot["secondary_weapon"],
							  bot["utility"],
							  bot["primary_color"],
							  bot["secondary_color"],
							  bot["accent_color"],
							  bot["animation"] ],
							bot["name"]):
							refresh_bots()
							print_success('I now bestow upon your bot the name ' + name)
						else:
							print_error('Ritual failed')
					else:
						print_error('You got that one wrong')
						
				_:
					print_error('What are you doing?')
		else:
			print_error('I got nothin\'')
			
	else:
		text = text.to_lower()
		match text:
			'hello':
				print_success('Hello to you as well')
			_:
				print_error('I don\'t understand what you\'re saying')

func print_success(text):
	tag_success.text = text
	tag_error.text   = ''

func print_error(text):
	tag_error.text   = text
	tag_success.text = ''

func refresh_bots():
	timer.wait_time = 5
	timer.start()

func _on_LineEdit_text_entered(new_text):
	process_command()

func _on_Timer_timeout():
	head.refresh_bots = true
