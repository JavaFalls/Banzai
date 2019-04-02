extends Node

const SAVE_TEXT = "Save the current AI changes?"
const ROLLBACK_TEXT = "Remove the current AI changes?"

var saving = false

signal leave
signal resume

func _ready():
	get_node("results_texture").set_texture(ResourceLoader.load("res://assets/nn_chart.png", "", true))
	$save_button.connect("pressed", self, "save")
	$rollback_button.connect("pressed", self, "rollback")
	$back_button.connect("pressed", self, "resume")
	$confirm/yes_button.connect("pressed", self, "yes_pressed")
	$confirm/no_button.connect("pressed", self, "no_pressed")
	
#	var GImage_File = File.new();
#
#	if (GImage_File.file_exists("res://Figure_1.png")):
#		GImage_File.open("res://Figure_1.png", GImage_File.READ);
#
#		var g_texture = GImage_File.get_var();
#		var new_img = ImageTexture.new();
#		new_img.create_from_image(g_texture);
#
#		GImage_File.close();
	
	# Image in python has to be cleared or else it will plot more points on top of the previous image.
	
	var img = ImageTexture.new()
	img.load("res://assets/nn_chart.png")
	$results_texture.texture = img

# Signal methods
#-------------------------------------------------------
func save():
	saving = true
	$confirm/Label.text = SAVE_TEXT
	$confirm.visible = true

func rollback():
	saving = false
	$confirm/Label.text = ROLLBACK_TEXT
	$confirm.visible = true

func resume():
	emit_signal("resume")

func yes_pressed():
	if saving:
		save_model()
	emit_signal("leave")

func no_pressed():
	$confirm.visible = false

# Save model
#-------------------------------------------------------
func save_model():
	print("saving model")
	head.save_bot()
	