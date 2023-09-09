extends Node

enum LobbyAvailability {PRIVATE, FRIENDS, PUBLIC, INVISIBLE}
var lobby_id = 0

func _ready():
	var _init_status = Steam.steamInit()

func _process(delta):
	Steam.run_callbacks()

