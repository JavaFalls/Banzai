extends Node

"""
A universal set of AudioStreamPlayer's are attached to specific busses.
Each player can only play one sound at a time.
A player can either override a current sound or wait for it to finish before playing.
"""

enum {
	BUTTON_ACCEPT, BUTTON_HOVER
}
onready var wavs = [
	preload("res://sounds/ui/button_accept.wav"),
	preload("res://sounds/ui/button_hover.wav")
]

var ui1
var ui2

func _ready():
	add_child(AudioStreamPlayer.new())
	add_child(AudioStreamPlayer.new())
	
	ui1 = get_child(0)
	ui1.set_stream(wavs[BUTTON_ACCEPT])
	ui1.set_bus("UI")
	ui1.set_volume_db(3)
	
	ui2 = get_child(1)
	ui2.set_stream(wavs[BUTTON_HOVER])
	ui2.set_bus("UI")

func play_stream(player, audio_index, wait=false):
	if not player is AudioStreamPlayer:
		print("Not an audio player")
	
# Comparision is getting 0==0 with different resources
#	if player.stream.get_rid().get_id() != wavs[audio_index].get_rid().get_id():
#		player.set_stream(wavs[audio_index])
	player.set_stream(wavs[audio_index])
	
	if wait and player.is_playing():
		yield(player, "finished")
	player.play()
