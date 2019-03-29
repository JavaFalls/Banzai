extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")
onready var intro_text = get_node("Container/VBoxContainer/intro_text")

onready var alpha = 0
onready var alpha_modifier = get_node("alpha_timer").wait_time

onready var popup_scene = preload("res://Scenes/popups/arena_end_popup.tscn")
var popup = null # An instanced popup scene

onready var name_choice_screen = preload("res://Scenes/name_choice.tscn").instance(PackedScene.GEN_EDIT_STATE_DISABLED)

func _ready():
	if(!Menu_audio.menu_audio.playing):
		Menu_audio.menu_audio.play()
	intro_text.visible = false # intro_text is not visible until we confirm we can connect to the DB

#func _process(delta):
#	pass
	
func _input(event):
	if event is InputEventKey and event.is_pressed() and head.DB.is_connection_open() and not Input.is_action_just_pressed("toggle_fullscreen"):
		create_user()

func create_user():
	name_choice_screen.get_node("confirm_button/Label").text = "n\ne\nw\n\np\nl\na\ny\ne\nr"
	add_child(name_choice_screen)
	yield(name_choice_screen, "name_entered")
	head.username = name_choice_screen.get_username()
	head.create_user() # create_user() must be run after head.username is set
	get_tree().change_scene("res://Scenes/main_menu.tscn")


func _on_alpha_timer_timeout():
	alpha += alpha_modifier
	if (alpha <= 0.0 || alpha >= 1.0):
		alpha_modifier = -alpha_modifier
	intro_text.modulate = Color(1,1,1,alpha)

func test_DB_connection():
	if head.DB.open_connection() == 0:
		# Connection failed, display a popup with the error to the user:
		popup = popup_scene.instance()
		self.add_child(popup)
		popup.init("Could not connect to the database.", "Retry", "Quit", self, "retry", self, "quit", "")
		popup.set_background_transparency(0.9)
	else:
		intro_text.visible = true

# Popup responder functions
func retry():
	get_tree().paused = false
	popup.queue_free()
	$test_DB_timer.start()

func quit():
	get_tree().paused = false
	get_tree().quit()

func _on_test_DB_timer_timeout():
	test_DB_connection()
