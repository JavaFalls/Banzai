extends Node

onready var head = get_tree().get_root().get_node("/root/head")

onready var _leaders = get_node("leaders")

# An index in one array corresponds to all other arrays
var players = [
	"Turing the Machine",
	"Turing the Machine",
	"A",
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
	2941,
	3,
	132987,
	2,
	3345,
	3344,
	14848,
	5,
	3333,
	79,
	-9,
	11691,
]
var bots = [
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://assets/Wall.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png"),
	load("res://icon.png")
]

func _ready():
	assign_leaders()
	sort()
	pass

func sort():
	var temp
	for i in range(1, scores.size()):
		var j = i
		while scores[j] > scores[j-1] and j > 0:
			temp = scores[j]
			scores[j] = scores[j-1]
			scores[j-1] = temp
			
			temp = players[j]
			players[j] = players[j-1]
			players[j-1] = temp
			
			temp = bots[j]
			bots[j] = bots[j-1]
			bots[j-1] = temp
			j -= 1
	assign_leaders()

func assign_leaders():
	var i = 0
	for leader in _leaders.get_children():
		if leader.name == "label":
			continue
		var bot = leader.get_node("TextureRect")
		var player_name = leader.get_node("Label")
		var score = leader.get_node("Label2")
		
		bot.texture = bots[i]
		player_name.text = players[i]
		score.text = str(scores[i])
		i += 1