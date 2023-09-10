extends Node

enum LobbyAvailability {PRIVATE, FRIENDS, PUBLIC, INVISIBLE}
var lobby_id = 0
var self_peer_id = -1

# If true then the game state wants the current player to take some action.
var has_priority = true

func _ready():
	var _init_status = Steam.steamInit()
	self_peer_id = Steam.getSteamID()

func _process(_delta):
	Steam.run_callbacks()

