extends Node

enum{SERVER_DOWN,SERVER_UP}
enum{SERVER_ERROR_SUCCESS}

var serverState

func _ready():
   serverState = SERVER_DOWN
