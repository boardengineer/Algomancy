extends Node

enum LobbyAvailability {PRIVATE, FRIENDS, PUBLIC, INVISIBLE}
var lobby_id = 0
var self_peer_id = -1

var latest_network_id = 0

var network_items_by_id = {}
var network_players_by_id = {}

# If true then the game state wants the current player to take some action.
var has_priority = true

var tracked_game_oj

func _ready():
	var _init_status = Steam.steamInit()
	self_peer_id = Steam.getSteamID()

func _process(_delta):
	Steam.run_callbacks()

func get_next_network_id() -> int:
	var result = latest_network_id
	latest_network_id += 1
	return result
