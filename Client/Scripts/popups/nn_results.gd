extends Node

signal save
signal rollback
signal go_back

func _ready():
	$back_button.connect("pressed", self, "go_back")
	
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
	$results_texture.texture = img #load("res://Figure_1.png")

func go_back():
	emit_signal("go_back")
