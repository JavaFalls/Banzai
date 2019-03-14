extends Node

"""
A universal set of AudioStreamPlayer's are attached to specific busses.
Each player can only play one sound at a time.
A player can either override a current sound or wait for it to finish before playing.
"""

enum {
	SCENE_CHANGE, BUTTON_HOVER,
	BOT_CHANGE_1, BOT_CHANGE_2, BOT_CHANGE_3
}
onready var wavs = [
	preload("res://sounds/ui/sci-fi_deep_electric_hum_loop_01.wav"),
	preload("res://sounds/ui/sci-fi_beep_computer_ui_06.wav"),
	preload("res://sounds/ui/sci-fi_power_up_05.wav"),
	preload("res://sounds/ui/sci-fi_power_up_07.wav"),
	preload("res://sounds/ui/sci-fi_power_up_09.wav")
]

var ui1
var ui2

func _ready():
	add_child(AudioStreamPlayer.new())
	add_child(AudioStreamPlayer.new())
	
	ui1 = get_child(0)
	ui1.set_stream(wavs[SCENE_CHANGE])
	ui1.set_bus("UI")
	
	ui2 = get_child(1)
	ui2.set_stream(wavs[SCENE_CHANGE])
	ui2.set_bus("UI")

func play_stream(player, audio_index, wait=false):
	if not player is AudioStreamPlayer:
		print("Not an audio player")
	
# Comparision is getting 0==0 with different resources
#	if player.stream.get_rid().get_id() != wavs[audio_index].get_rid().get_id():
#		player.set_stream(wavs[audio_index])
	if wait and player.playing:
		yield(player, "finished")
	player.set_stream(wavs[audio_index])
	player.play()
