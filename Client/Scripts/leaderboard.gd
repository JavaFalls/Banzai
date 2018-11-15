extends Node

onready var head = get_tree().get_root().get_node("/root/head")

onready var _leaders = get_node("leaders")

# An index in one array corresponds to all other arrays
var players = [
	"Turing the Machine",
	"Turing the Machine",
	"Turing the Machine",
	"Turing the Machine",
	"Turing the Machine",
	"Turing the Machine",
	"Turing the Machine",
	"Turing the Machine",
	"Turing the Machine",
	"Turing the Machine",
	"Turing the Machine",
	"Turing the Machine"
]
var scores = [
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1,
	1
]
var bots = [
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png")
]

func _ready():
	var p = 0
	for leader in _leaders.get_children():
		var bot = leader.get_node("TextureRect")
		var player_name = leader.get_node("Label")
		var score = leader.get_node("Label2")
		
		bot.texture = bots[p]
		player_name.text = players[p]
		score.text = str(scores[p])
	pass
