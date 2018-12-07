extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_text(str(head.score_change))
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
