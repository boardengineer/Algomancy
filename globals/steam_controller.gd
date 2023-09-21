extends Node

signal draft_complete_or_cancelled
signal activated_ability_or_passed_or_cancelled

enum LobbyAvailability {PRIVATE, FRIENDS, PUBLIC, INVISIBLE}
var lobby_id = 0
var self_peer_id = -1
var is_host = true

var latest_network_id = 0

var network_items_by_id = {}
var network_players_by_id = {}

# If true then the game state wants the current player to take some action.
var has_priority = true

var waiting_for_draft = false

var draft_selection_by_player_id = {}

var tracked_players = {}

func _ready():
	var _init_status = Steam.steamInit()
	self_peer_id = Steam.getSteamID()
	
	var _unused = GameController.connect("cancel", self, "_on_cancelled")
	_unused = Steam.connect("lobby_joined", self, "_on_Lobby_Joined")

func _process(_delta):
	Steam.run_callbacks()

func start_game(f_is_host = true) -> void:
	var main_scene = load("res://main.tscn").instance()
	
	is_host = f_is_host
	
	get_tree().get_root().add_child(main_scene)
	get_tree().set_current_scene(main_scene)

func get_next_network_id() -> int:
	var result = latest_network_id
	latest_network_id += 1
	return result

func start_draft() -> void:
	waiting_for_draft = true
	draft_selection_by_player_id = {}

func complete_draft() -> void:
	waiting_for_draft = false
	emit_signal("draft_complete_or_cancelled")

func receive_draft_selection(player_id, selected_network_ids) -> void:
	if not waiting_for_draft:
		return
	
	var deindexed_card_list = []
	for id_selected in selected_network_ids:
		deindexed_card_list.push_back(network_items_by_id[id_selected])
	draft_selection_by_player_id[player_id] = deindexed_card_list
	
	if draft_selection_by_player_id.size() == network_players_by_id.size():
		complete_draft()

func submit_ability_or_passed(command) -> void:
	if is_host:
		receive_ability_or_pass(command)
	pass

func receive_ability_or_pass(command) -> void:
	network_items_by_id[command.source].activate_ability(command.index, command.effects)

func submit_draft_selection(draft_selection) -> void:
	var selected_card_ids = []
	for card in draft_selection:
		selected_card_ids.push_back(card.network_id)
	if is_host:
		receive_draft_selection(self_peer_id, selected_card_ids)
	else:
		# Send draft selection to host
		pass
	pass

func submit_formation(formation_dict:Dictionary) -> void:
	pass
 
func receive_formation(formation_dict:Dictionary) -> void:
	pass

func _on_cancelled():
	emit_signal("draft_complete_or_cancelled")

func send_handshakes() -> void:
	var send_data = {}
	send_data["type"] = "handshake"
	send_data_to_all(send_data)

func send_data_to_all(packet_data: Dictionary) -> void:
	for player_id in tracked_players:
		if player_id == self_peer_id:
			continue
		send_data(packet_data, player_id)

func send_data(packet_data: Dictionary, target: int, channel:int = 0) -> void:
	# TODO actually compress
	var compressed_data = var2bytes(packet_data).compress(File.COMPRESSION_GZIP)
	
	# Just use channel 0 for everything for now
	var _error = Steam.sendP2PPacket(target, compressed_data, Steam.P2P_SEND_RELIABLE, channel)

# clears tracked_players and resets tracked players based  
func update_tracked_players() -> void:
	# Clear your previous lobby list
	tracked_players.clear()

	# Get the number of members from this lobby from Steam
	var num_members = Steam.getNumLobbyMembers(lobby_id)
#	var all_players_ready = true

	# Get the data of these players from Steam
	for member_index in range(num_members):
		var member_steam_id = Steam.getLobbyMemberByIndex(lobby_id, member_index)
		var member_username: String = Steam.getFriendPersonaName(member_steam_id)
		
#		if not established_p2p_connections.has(member_steam_id) or not established_p2p_connections[member_steam_id]:
#			if member_steam_id != parent.self_peer_id:
#				all_players_ready = false
#				if parent.is_host:
#					member_username = member_username + " (loading)"
		
		tracked_players[member_steam_id] = {"username": member_username}


func _on_Lobby_Joined(joined_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	print_debug("on lobby joined")
	if response == 1:
		SteamController.lobby_id = joined_lobby_id
		var _scene_error = get_tree().change_scene("res://multiplayer_lobby.tscn")
		update_tracked_players()
		send_handshakes()
		
#		if not parent.is_host:
#			request_lobby_update()
