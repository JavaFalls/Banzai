extends Node

# TODO:
# - Add code to allow the highlighted bot to be changed (low priority)
#

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_LEADERS = "screen_layout/HBoxContainer/left_side_of_screen/leaders"
const NP_TIMER = "timer"

# Pre initialized variables
#-------------------------------------------------------------------------------
onready var DB = DBConnector.new()
onready var _leaders = get_node(NP_LEADERS)
onready var _timer = get_node(NP_TIMER)

export(float, 0, 10) var request_pause = 1

func _ready():
	OS.center_window()
	_timer.wait_time = request_pause
	_timer.start()
	_timer.connect("timeout", self, "request")
	
	# Initialize scoreboard_entries
	var i = 1
	for scoreboard_entry in _leaders.get_children():
		scoreboard_entry.set_position(i)
		match i % 3:
			1:
				scoreboard_entry.set_tag_color(scoreboard_entry.TAG_BLUE)
			2:
				scoreboard_entry.set_tag_color(scoreboard_entry.TAG_RED)
			0:
				scoreboard_entry.set_tag_color(scoreboard_entry.TAG_GREEN)
		
		i += 1

# Updates the scoreboard data from hte database
func request():
	# Get data
	var raw_JSON = DB.get_scoreboard_top_ten()
	if (raw_JSON != ""):
		var scoreboard_dictionary = JSON.parse(raw_JSON).result["data"]
		
		# Place data on scoreboard
		var i = 0
		if (i < scoreboard_dictionary.size()):
			get_node("graphics/animation_bot").load_colors_from_DB(scoreboard_dictionary[0]["bot_ID_PK"])
			get_node("right_side_of_screen/robot_name").text = scoreboard_dictionary[0]["name"]
			get_node("graphics/animation_bot").visible = true
			get_node("right_side_of_screen/robot_name").visible = true
		else:
			get_node("graphics/animation_bot").visible = false
			get_node("right_side_of_screen/robot_name").visible = false
		for scoreboard_entry in _leaders.get_children():
			if (i < scoreboard_dictionary.size()):
				scoreboard_entry.set_name(scoreboard_dictionary[i]["name"])
				scoreboard_entry.set_score(scoreboard_dictionary[i]["ranking"])
			else: 
				scoreboard_entry.set_name("")
				scoreboard_entry.set_score("-")
			
			i += 1