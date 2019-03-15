extends Node

onready var head = get_tree().get_root().get_node("/root/head")

# Constants:
#  NP = "Node Path"
#  FP = "File Path"
#-------------------------------------------------------------------------------
const NP_REFRESH_TIMER = "refresh_timer"
const NP_SCOREBOARD_UP = "ui_layout/HBoxContainer/left_side_of_screen/scoreboard/scoreboard_entry_up"
const NP_SCOREBOARD_DOWN = "ui_layout/HBoxContainer/left_side_of_screen/scoreboard/scoreboard_entry_down"
const NP_SCOREBOARD = "ui_layout/HBoxContainer/left_side_of_screen/scoreboard"

const NP_PLAYER_HIGHLIGHT_NAME = "player_bot_highlight/player_name"
const NP_PLAYER_HIGHLIGHT_POSITION = "player_bot_highlight/position"
const NP_PLAYER_HIGHLIGHT_SCORE = "player_bot_highlight/score"

const NP_PLAYER_BOT_GRAPHICS = "graphics/animation_bot"

const PLAYER_BOT_DEFAULT_DISPLAY_SPOT = 5 # The scoreboard_entry that the player's bot will be displayed on when the screen first loads
const MIN_DISPLAY_POSITION = 0 # The scoreboard won't scroll past this point
const DB_GRAB_POSITIONS = 50 # How many positions to load around the current display position
const MAX_SCOREBOARD_DICTIONARY_SIZE = DB_GRAB_POSITIONS + DB_GRAB_POSITIONS + 1

# Exported values:
#-------------------------------------------------------------------------------

# Internal Variables:
#-------------------------------------------------------------------------------
var scoreboard_dictionary # The current values loaded from the DB
var scoreboard_dictionary_size # The current size of the scoreboard_dictionary
var scoreboard_dictionary_index_offset # The difference between a bots actual position on the scoreboard and its index in the scoreboard_dictionary

var display_position # The current smallest position number that is displayed on the scoreboard.- In other words, the scoreboard position of the bot display on the UP button banner

# Pre initialized variables
#-------------------------------------------------------------------------------
onready var scoreboard = get_node(NP_SCOREBOARD)

# Godot Hooks:
#-------------------------------------------------------------------------------
func _ready():
	# Called when the node is added to the scene for the first time.
	var refresh_timer = get_node(NP_REFRESH_TIMER)
	refresh_timer.start()
	refresh_timer.connect("timeout", self, "request")
	get_node(NP_SCOREBOARD_UP).connect("on_click", self, "scoreboard_entry_up_on_click")
	get_node(NP_SCOREBOARD_DOWN).connect("on_click", self, "scoreboard_entry_down_on_click")

### TEST ###
	var bot_id = head.bot_ID
	if bot_id == -1:
		bot_id = 1
############
	# Initialize scoreboard
	display_position = head.DB.get_scoreboard_position(bot_id) - PLAYER_BOT_DEFAULT_DISPLAY_SPOT
	if (display_position < MIN_DISPLAY_POSITION):
		display_position = MIN_DISPLAY_POSITION
	get_scoreboard_dictionary()
	get_node(NP_PLAYER_BOT_GRAPHICS).load_colors_from_DB(bot_id)
	update_player_bot_highlight()
	update_scoreboard_ui()

func _input(event):
	if (Input.is_action_just_pressed("ui_scroll_up")):
		move_scoreboard_display(-1)
	if (Input.is_action_just_pressed("ui_scroll_down")):
		move_scoreboard_display(1)

# Signal Responders
#-------------------------------------------------------------------------------
func request():
	get_scoreboard_dictionary()
	update_player_bot_highlight()
	update_scoreboard_ui()

func scoreboard_entry_up_on_click():
	move_scoreboard_display(-1)

func scoreboard_entry_down_on_click():
	move_scoreboard_display(1)

func _on_back_button_pressed():
	head.play_stream(head.ui2, head.sounds.SCENE_CHANGE, head.options.WAIT)
	get_tree().change_scene("res://Scenes/main_menu.tscn")

func button_hover():
	head.play_stream(head.ui1, head.sounds.BUTTON_HOVER)

# Functions:
#-------------------------------------------------------------------------------
# Updates the scoreboard_dictionary with fresh data from the DB.
# Assumes display_position contains a value
func get_scoreboard_dictionary():
	var raw_JSON = head.DB.get_scoreboard_range(display_position - DB_GRAB_POSITIONS, display_position + DB_GRAB_POSITIONS)
	if (raw_JSON != ""):
		scoreboard_dictionary = JSON.parse(raw_JSON).result["data"]
		scoreboard_dictionary_size = scoreboard_dictionary.size()
		if (scoreboard_dictionary_size > 0):
			scoreboard_dictionary_index_offset = scoreboard_dictionary[0]["position"]
		else:
			scoreboard_dictionary_index_offset = -1

# Updates the scoreboard UI
func update_scoreboard_ui():
	# Check if we need to reload data from the DB
	if (display_position < scoreboard_dictionary[0]["position"] || display_position + 11 > scoreboard_dictionary[scoreboard_dictionary_size - 1]["position"]):
		get_scoreboard_dictionary()

	var i = display_position - scoreboard_dictionary_index_offset
	for scoreboard_entry in scoreboard.get_children():
		if (i >= 0 && i < scoreboard_dictionary_size):
			# Data is currently loaded for this position, so we can display it on the scoreboard
			scoreboard_entry.set_position(scoreboard_dictionary[i]["position"])
			scoreboard_entry.set_name(scoreboard_dictionary[i]["name"])
			scoreboard_entry.set_score(scoreboard_dictionary[i]["ranking"])
		else:
			# Position does not exist in the DB, so we need to display a blank banner
			scoreboard_entry.set_position(i + scoreboard_dictionary_index_offset)
			scoreboard_entry.set_name("")
			scoreboard_entry.set_score("-")

		match scoreboard_entry.get_position() % 3:
			1:
				scoreboard_entry.set_tag_color(scoreboard_entry.TAG_BLUE)
			2:
				scoreboard_entry.set_tag_color(scoreboard_entry.TAG_RED)
			0:
				scoreboard_entry.set_tag_color(scoreboard_entry.TAG_GREEN)

		i += 1

# Updates the player's bot information with the latest data from the database
func update_player_bot_highlight():
	get_node(NP_PLAYER_HIGHLIGHT_POSITION).text = "Rank: " + String(head.DB.get_scoreboard_position(head.bot_ID))
	
### TEST ###
	var bot_id = head.bot_ID
	if bot_id == -1:
		bot_id = 1
############
	var score_raw_JSON = head.DB.get_bot(bot_id)
	if (score_raw_JSON != ""):
		get_node(NP_PLAYER_HIGHLIGHT_SCORE).text = "Score: " + String(JSON.parse(score_raw_JSON).result["data"][0]["ranking"])
	pass

# Updates the scoreboard display by moving the displayed positions by the specified amount
func move_scoreboard_display(amount):
	display_position += amount
	if (display_position < MIN_DISPLAY_POSITION):
		display_position = MIN_DISPLAY_POSITION
	elif(scoreboard_dictionary_size < MAX_SCOREBOARD_DICTIONARY_SIZE && display_position - scoreboard_dictionary_index_offset >= scoreboard_dictionary_size):
		display_position = scoreboard_dictionary[scoreboard_dictionary_size - 1]["position"]
	update_scoreboard_ui()
