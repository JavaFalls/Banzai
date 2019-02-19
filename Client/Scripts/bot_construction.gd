extends Node

# Get head singleton
onready var head = get_tree().get_root().get_node("/root/head")

func _ready():
	get_node("item_scroll").items = head.weapons.values()
